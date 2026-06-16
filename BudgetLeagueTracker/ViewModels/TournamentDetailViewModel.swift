import Foundation
import SwiftData

/// Tab for ongoing tournament detail.
enum TournamentDetailTab: String, CaseIterable {
    case attendance = "Attendance"
    case pods = "Pods"
    case standings = "Standings"
}

/// Host-facing step within the current week workflow.
enum TournamentHostStep {
    case attendance
    case pods
    case scoreRound
}

/// ViewModel for the Tournament Detail view.
/// Manages tournament landing page including pods, standings, and navigation.
/// Absorbs functionality from PodsViewModel for ongoing tournaments.
@Observable
final class TournamentDetailViewModel {
    private let context: ModelContext
    let tournamentId: String
    
    // MARK: - Published State
    
    var tournament: Tournament?
    var pods: [[Player]] = []
    var activeAchievements: [Achievement] = []
    
    /// Active tab for ongoing tournaments (Attendance | Pods | Standings).
    var activeTab: TournamentDetailTab = .attendance
    /// Selected week for standings: nil = overall/tournament total, 1...totalWeeks = that week.
    var selectedStandingsWeek: Int? = nil
    /// Which pod sections are expanded in the Pods tab.
    var expandedPodIndices: Set<Int> = []
    
    private var allPlayers: [Player] = []
    private var podHistoryCount: Int = 0
    
    // MARK: - Navigation State
    
    var showAttendance: Bool = false
    var showEditLastRound: Bool = false
    var showWeekCompleteSheet: Bool = false
    var completedWeekNumber: Int?
    
    // MARK: - Computed Properties: Tournament Info
    
    var tournamentName: String {
        tournament?.name ?? "Tournament"
    }
    
    var isOngoing: Bool {
        tournament?.status == .ongoing
    }
    
    var isCompleted: Bool {
        tournament?.status == .completed
    }
    
    var currentWeek: Int {
        tournament?.currentWeek ?? 1
    }
    
    var totalWeeks: Int {
        tournament?.totalWeeks ?? 1
    }
    
    var currentRound: Int {
        tournament?.currentRound ?? 1
    }
    
    var achievementsOnThisWeek: Bool {
        tournament?.achievementsOnThisWeek ?? true
    }
    
    var dateRangeString: String {
        tournament?.dateRangeString ?? ""
    }
    
    var weekProgressString: String {
        "Week \(currentWeek) of \(totalWeeks)"
    }
    
    var roundString: String {
        "Round \(currentRound)"
    }

    /// Whether pods have been generated or scored for the current round.
    var hasScoredCurrentRound: Bool {
        !pods.isEmpty || hasRoundPlacementsForPresentPlayers
    }

    /// Current step in the weekly host workflow.
    var hostStep: TournamentHostStep {
        if !hasPresentPlayers { return .attendance }
        if !hasScoredCurrentRound { return .pods }
        return .scoreRound
    }

    /// Short hint describing what the host should do next.
    var nextStepHint: String {
        switch hostStep {
        case .attendance:
            return "Mark who's here this week"
        case .pods:
            return "Generate pods for Round \(currentRound)"
        case .scoreRound:
            if currentRound < AppConstants.League.roundsPerWeek {
                return "Set placements, then finish Round \(currentRound)"
            }
            if tournament?.isFinalWeek == true {
                return "Set placements, then end the tournament"
            }
            return "Set placements, then end Week \(currentWeek)"
        }
    }

    /// Steps for the progress header.
    var progressSteps: [TournamentProgressStep] {
        let attendanceState: TournamentProgressStepState = hasPresentPlayers ? .complete : .current
        let podsState: TournamentProgressStepState = {
            if !hasPresentPlayers { return .upcoming }
            if hasScoredCurrentRound { return .complete }
            return .current
        }()
        let scoreState: TournamentProgressStepState = {
            if !hasScoredCurrentRound { return .upcoming }
            return .current
        }()

        return [
            TournamentProgressStep(id: "attendance", title: "Attendance", state: attendanceState),
            TournamentProgressStep(id: "pods", title: "Pods", state: podsState),
            TournamentProgressStep(id: "score", title: "Score", state: scoreState)
        ]
    }

    /// Label for the generate-pods action.
    var generatePodsButtonTitle: String {
        "Generate Round \(currentRound) Pods"
    }

    /// Whether any present player has scored points this week.
    var hasWeeklyStandingsToShow: Bool {
        weeklyStandings.contains { $0.points.total > 0 }
    }

    /// Top weekly standings rows for inline display on the Pods tab.
    var inlineWeeklyStandings: [(player: Player, points: WeeklyPlayerPoints)] {
        let ranked = weeklyStandings.filter { $0.points.total > 0 }
        return Array(ranked.prefix(5))
    }

    /// Standings for the week that just ended (week-complete sheet).
    var completedWeekStandings: [(player: Player, points: Int, placementPoints: Int, achievementPoints: Int)] {
        guard let week = completedWeekNumber else { return [] }
        return weekStandings(week: week)
    }
    
    var presentPlayerIds: [String] {
        tournament?.presentPlayerIds ?? []
    }
    
    var hasPresentPlayers: Bool {
        !presentPlayerIds.isEmpty
    }

    var podLayoutHint: String? {
        PodLayoutHint.message(presentCount: presentPlayerIds.count)
    }
    
    // MARK: - Computed Properties: Pod Management
    
    var canGeneratePods: Bool {
        hasPresentPlayers
    }
    
    var canEdit: Bool {
        podHistoryCount > 0
    }

    /// True when every present player has a placement recorded for the current round.
    var hasRoundPlacementsForPresentPlayers: Bool {
        guard hasPresentPlayers, let tournament = tournament else { return false }
        return presentPlayerIds.allSatisfy { tournament.roundPlacements[$0] != nil }
    }

    /// Whether the host can advance to the next round or week.
    var canNextRound: Bool {
        hasPresentPlayers && (!pods.isEmpty || hasRoundPlacementsForPresentPlayers)
    }

    /// Primary label for the advance-round action.
    var nextRoundButtonTitle: String {
        guard tournament != nil else { return "Next Round" }
        if currentRound < AppConstants.League.roundsPerWeek {
            return "Finish Round \(currentRound)"
        }
        if tournament?.isFinalWeek == true {
            return "End Tournament"
        }
        return "End Week & Show Standings"
    }

    /// Alert title when confirming round/week advancement.
    var nextRoundConfirmationTitle: String {
        guard tournament != nil else { return "Finish round?" }
        if currentRound < AppConstants.League.roundsPerWeek {
            return "Finish Round \(currentRound)?"
        }
        if tournament?.isFinalWeek == true {
            return "End tournament?"
        }
        return "End Week \(currentWeek)?"
    }

    /// Alert message when confirming round/week advancement.
    var nextRoundConfirmationMessage: String {
        guard tournament != nil else {
            return "This will save current scores and continue."
        }
        if currentRound < AppConstants.League.roundsPerWeek {
            return "This saves Round \(currentRound) scores and starts Round \(currentRound + 1)."
        }
        if tournament?.isFinalWeek == true {
            return "This saves the final round and completes the tournament."
        }
        return "This saves the week and starts Week \(currentWeek + 1) attendance."
    }

    /// Destructive confirm button label in the advancement alert.
    var nextRoundConfirmActionTitle: String {
        if currentRound < AppConstants.League.roundsPerWeek {
            return "Finish Round"
        }
        if tournament?.isFinalWeek == true {
            return "End Tournament"
        }
        return "End Week"
    }
    
    /// Weekly standings for inline display, sorted by total points descending.
    var weeklyStandings: [(player: Player, points: WeeklyPlayerPoints)] {
        guard let tournament = tournament else { return [] }
        let weeklyPoints = tournament.weeklyPointsByPlayer
        
        let presentPlayers = allPlayers.filter { presentPlayerIds.contains($0.id) }
        
        return presentPlayers
            .map { player in
                (player: player, points: weeklyPoints[player.id] ?? WeeklyPlayerPoints())
            }
            .sorted { $0.points.total > $1.points.total }
    }
    
    // MARK: - Computed Properties: Standings
    
    /// All game results for this tournament.
    private var tournamentResults: [GameResult] {
        guard let tournament = tournament else { return [] }
        return StatsEngine.fetchResultsForTournament(tournament.id, context: context)
    }
    
    /// Overall/tournament standings (all results summed). Used for both ongoing and completed.
    var overallStandings: [(player: Player, points: Int, placementPoints: Int, achievementPoints: Int, wins: Int)] {
        guard tournament != nil else { return [] }
        let results = tournamentResults
        var playerStats: [String: (points: Int, placementPoints: Int, achievementPoints: Int, wins: Int)] = [:]
        for result in results {
            let current = playerStats[result.playerId] ?? (0, 0, 0, 0)
            playerStats[result.playerId] = (
                points: current.points + result.totalPoints,
                placementPoints: current.placementPoints + result.placementPoints,
                achievementPoints: current.achievementPoints + result.achievementPoints,
                wins: current.wins + (result.isWin ? 1 : 0)
            )
        }
        return playerStats
            .compactMap { playerId, stats -> (player: Player, points: Int, placementPoints: Int, achievementPoints: Int, wins: Int)? in
                guard let player = allPlayers.first(where: { $0.id == playerId }) else { return nil }
                return (player: player, points: stats.points, placementPoints: stats.placementPoints, achievementPoints: stats.achievementPoints, wins: stats.wins)
            }
            .sorted { $0.points > $1.points }
    }
    
    /// Standings for a specific week (from game results).
    func weekStandings(week: Int) -> [(player: Player, points: Int, placementPoints: Int, achievementPoints: Int)] {
        let results = tournamentResults.filter { $0.week == week }
        var playerStats: [String: (points: Int, placementPoints: Int, achievementPoints: Int)] = [:]
        for result in results {
            let current = playerStats[result.playerId] ?? (0, 0, 0)
            playerStats[result.playerId] = (
                points: current.points + result.totalPoints,
                placementPoints: current.placementPoints + result.placementPoints,
                achievementPoints: current.achievementPoints + result.achievementPoints
            )
        }
        return playerStats
            .compactMap { playerId, stats -> (player: Player, points: Int, placementPoints: Int, achievementPoints: Int)? in
                guard let player = allPlayers.first(where: { $0.id == playerId }) else { return nil }
                return (player: player, points: stats.points, placementPoints: stats.placementPoints, achievementPoints: stats.achievementPoints)
            }
            .sorted { $0.points > $1.points }
    }
    
    /// Standings options for the week picker: Tournament (overall) + Week 1..N.
    var standingsWeekOptions: [(label: String, week: Int?)] {
        guard let tournament = tournament else { return [("Tournament", nil)] }
        var options: [(String, Int?)] = [("Tournament", nil)]
        for w in 1...tournament.totalWeeks {
            options.append(("Week \(w)", w))
        }
        return options
    }

    /// VoiceOver label for the standings week menu picker.
    var standingsWeekPickerLabel: String {
        if let week = selectedStandingsWeek {
            return "Week \(week)"
        }
        return "Tournament overall"
    }
    
    /// Standings to display based on selectedStandingsWeek (overall or specific week).
    var standingsForDisplay: [(player: Player, totalPoints: Int, placementPoints: Int, achievementPoints: Int, wins: Int?)] {
        if let week = selectedStandingsWeek {
            return weekStandings(week: week).map { ($0.player, $0.points, $0.placementPoints, $0.achievementPoints, nil as Int?) }
        }
        return overallStandings.map { ($0.player, $0.points, $0.placementPoints, $0.achievementPoints, $0.wins as Int?) }
    }
    
    /// Final standings for completed tournaments (same as overallStandings when completed).
    var finalStandings: [(player: Player, points: Int, placementPoints: Int, achievementPoints: Int, wins: Int)] {
        guard tournament?.status == .completed else { return [] }
        return overallStandings
    }
    
    /// Winner name for completed tournaments.
    var winnerName: String? {
        guard let winner = finalStandings.first?.player else { return nil }
        return displayName(for: winner)
    }
    
    // MARK: - Initialization
    
    init(context: ModelContext, tournamentId: String) {
        self.context = context
        self.tournamentId = tournamentId
        refresh()
    }
    
    // MARK: - Actions: Refresh
    
    /// Refreshes state from SwiftData.
    func refresh() {
        // Fetch tournament
        tournament = LeagueEngine.fetchTournament(context: context, id: tournamentId)
        
        // Fetch all players
        let playerDescriptor = FetchDescriptor<Player>()
        allPlayers = (try? context.fetch(playerDescriptor)) ?? []
        
        // Fetch achievements
        let achievementDescriptor = FetchDescriptor<Achievement>()
        let allAchievements = (try? context.fetch(achievementDescriptor)) ?? []
        
        if let tournament = tournament {
            podHistoryCount = tournament.podHistorySnapshots.count
            syncActiveTab(for: tournament)

            // Filter to active achievements
            activeAchievements = allAchievements.filter { tournament.activeAchievementIds.contains($0.id) }
        }
    }

    /// Routes to the tab that matches tournament progress for this week.
    private func syncActiveTab(for tournament: Tournament) {
        if tournament.presentPlayerIds.isEmpty {
            activeTab = .attendance
        } else if activeTab == .attendance {
            activeTab = .pods
        }
    }
    
    // MARK: - Actions: Pod Management
    
    /// Generates pods for the current round.
    func generatePods() {
        guard let tournament = tournament else { return }
        
        pods = LeagueEngine.generatePodsForRound(
            players: allPlayers,
            presentPlayerIds: presentPlayerIds,
            currentRound: currentRound,
            weeklyPointsByPlayer: tournament.weeklyPointsByPlayer
        )
        
        // Clear any previous round data first
        LeagueEngine.clearRoundData(context: context)
        
        // Initialize placements with defaults and auto-save
        for pod in pods {
            for (index, player) in pod.enumerated() {
                let defaultPlace = min(index + 1, 4)
                LeagueEngine.updatePlacement(context: context, playerId: player.id, placement: defaultPlace)
            }
        }
        resetPodExpansion()
        refresh()
    }

    /// Expands only the first pod by default after generation.
    func resetPodExpansion() {
        expandedPodIndices = pods.isEmpty ? [] : [0]
    }

    func isPodExpanded(_ index: Int) -> Bool {
        expandedPodIndices.contains(index)
    }

    func setPodExpanded(_ index: Int, expanded: Bool) {
        if expanded {
            expandedPodIndices.insert(index)
        } else {
            expandedPodIndices.remove(index)
        }
    }
    
    /// Sets placement for a player (auto-saves immediately).
    func setPlacement(for playerId: String, place: Int) {
        LeagueEngine.updatePlacement(context: context, playerId: playerId, placement: place)
    }
    
    /// Returns placement for a player (default 4).
    func placement(for playerId: String) -> Int {
        guard let tournament = tournament else { return 4 }
        return tournament.roundPlacements[playerId] ?? 4
    }
    
    /// Toggles an achievement check for a player (auto-saves immediately).
    func toggleAchievementCheck(playerId: String, achievementId: String) {
        let currentlyChecked = isAchievementChecked(playerId: playerId, achievementId: achievementId)
        let podPlayerIds = pods.first(where: { pod in pod.contains(where: { $0.id == playerId }) })?.map(\.id)
        LeagueEngine.updateAchievementCheck(
            context: context,
            playerId: playerId,
            achievementId: achievementId,
            checked: !currentlyChecked,
            podPlayerIds: podPlayerIds
        )
    }

    /// Whether the achievement toggle should be disabled for a player.
    func isAchievementCheckDisabled(playerId: String, achievementId: String) -> Bool {
        guard !isAchievementChecked(playerId: playerId, achievementId: achievementId),
              let tournament,
              let achievement = activeAchievements.first(where: { $0.id == achievementId }),
              achievement.exclusivity == .onePerWeekPerPlayer else {
            return false
        }

        return LeagueEngine.playerHasEarnedAchievementThisWeek(
            context: context,
            tournamentId: tournament.id,
            week: tournament.currentWeek,
            playerId: playerId,
            achievementId: achievementId,
            excludingRound: tournament.currentRound
        )
    }
    
    /// Returns whether an achievement is checked for a player.
    func isAchievementChecked(playerId: String, achievementId: String) -> Bool {
        guard let tournament = tournament else { return false }
        return tournament.roundAchievementChecks.contains("\(playerId):\(achievementId)")
    }
    
    /// Opens the edit view for the last completed round.
    func editLastRound() {
        showEditLastRound = true
    }
    
    /// Called when the edit last round view saves changes.
    func onEditLastRoundSaved() {
        pods = []
        resetPodExpansion()
        refresh()
    }
    
    /// Advances to the next round or next week.
    func nextRound() {
        let endingWeek = currentWeek
        let isEndOfWeek = currentRound >= AppConstants.League.roundsPerWeek
        let wasFinalWeek = tournament?.isFinalWeek ?? false

        LeagueEngine.nextRound(context: context)
        pods = []
        resetPodExpansion()
        refresh()

        if isEndOfWeek, !wasFinalWeek {
            completedWeekNumber = endingWeek
            showWeekCompleteSheet = true
        }
    }

    /// Dismisses the week-complete sheet after the host reviews standings.
    func dismissWeekCompleteSheet() {
        showWeekCompleteSheet = false
        completedWeekNumber = nil
        activeTab = .attendance
    }
    
    // MARK: - Actions: Navigation
    
    /// Sets this tournament as the active tournament.
    func setAsActiveTournament() {
        guard let state = LeagueEngine.fetchLeagueState(context: context) else { return }
        state.activeTournamentId = tournamentId
        try? context.save()
    }
    
    /// Presents the attendance sheet (caller presents via .sheet(isPresented: $viewModel.showAttendance)).
    func goToAttendance() {
        setAsActiveTournament()
        showAttendance = true
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: allPlayers)
    }
}
