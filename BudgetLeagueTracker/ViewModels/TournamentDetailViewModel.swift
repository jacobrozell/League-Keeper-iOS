import Foundation
import SwiftData

/// Tab for ongoing tournament detail.
enum TournamentDetailTab: String, CaseIterable {
    case attendance = "Attendance"
    case round = "Round"
    case standings = "Standings"
}

/// Host-facing step within the current week workflow.
enum TournamentHostStep {
    case attendance
    case seatPlayers
    case scoreRound
}

/// Phase within the current round on the Round tab.
enum RoundPhase: Equatable {
    case seating
    case seatingsReady
    case scoring
    case review
}

/// ViewModel for the Tournament Detail view.
/// Manages tournament landing page including pods, standings, and navigation.
/// Absorbs functionality from PodsViewModel for ongoing tournaments.
@MainActor
@Observable
final class TournamentDetailViewModel {
    private let context: ModelContext
    let tournamentId: String
    
    // MARK: - Published State
    
    var tournament: Tournament?
    var pods: [[Player]] = []
    var activeAchievements: [Achievement] = []
    
    /// Active tab for ongoing tournaments (Attendance | Round | Standings).
    var activeTab: TournamentDetailTab = .attendance
    /// Whether the host has manually chosen a tab (don't override on refresh).
    private var hasUserSelectedTab = false
    /// Selected week for standings: nil = overall/tournament total, 1...totalWeeks = that week.
    var selectedStandingsWeek: Int? = nil
    /// Index of the table currently being scored.
    var currentScoringTableIndex: Int = 0
    
    private var allPlayers: [Player] = []
    private var podHistoryCount: Int = 0

    /// Non-nil when the most recent save failed; views show a toast and clear this.
    private(set) var persistenceErrorMessage: String?
    
    // MARK: - Navigation State
    
    var showEditLastRound: Bool = false
    var editSnapshotIndex: Int?
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

    var tournamentRules: TournamentRules {
        tournament?.rules ?? AppConstants.TournamentRulesDefaults.defaultRules
    }
    
    var weekProgressString: String {
        "Week \(currentWeek) of \(totalWeeks)"
    }
    
    var roundString: String {
        "Round \(currentRound) of \(AppConstants.League.roundsPerWeek)"
    }

    /// Whether tables have been seated for the current round.
    var hasPodsForCurrentRound: Bool {
        !pods.isEmpty
    }

    /// Alias for table-oriented UI copy.
    var hasTablesForCurrentRound: Bool {
        hasPodsForCurrentRound
    }

    var confirmedTableIndices: Set<Int> {
        tournament?.confirmedTableIndices ?? []
    }

    var allTablesConfirmed: Bool {
        hasPodsForCurrentRound && confirmedTableIndices.count == pods.count
    }

    var scoredTablesCount: Int {
        confirmedTableIndices.count
    }

    var roundScoringStarted: Bool {
        tournament?.roundScoringStarted ?? false
    }

    /// Current phase of the guided round flow.
    var roundPhase: RoundPhase {
        guard hasPresentPlayers else { return .seating }
        guard hasPodsForCurrentRound else { return .seating }
        if allTablesConfirmed { return .review }
        if roundScoringStarted { return .scoring }
        return .seatingsReady
    }

    /// Current step in the weekly host workflow.
    var hostStep: TournamentHostStep {
        if !hasPresentPlayers { return .attendance }
        if !hasPodsForCurrentRound { return .seatPlayers }
        return .scoreRound
    }

    /// Short hint describing what the host should do next.
    var nextStepHint: String {
        switch hostStep {
        case .attendance:
            return "Mark who's here this week"
        case .seatPlayers:
            return "Seat players at tables of four for Round \(currentRound)"
        case .scoreRound:
            switch roundPhase {
            case .seatingsReady:
                return "Review tables, then start scoring"
            case .scoring:
                return "Score Table \(currentScoringTableIndex + 1) of \(pods.count)"
            case .review:
                if currentRound < AppConstants.League.roundsPerWeek {
                    return "Review results, then finish Round \(currentRound)"
                }
                if tournament?.isFinalWeek == true {
                    return "Review results, then end the tournament"
                }
                return "Review results, then end Week \(currentWeek)"
            case .seating:
                return "Seat players for Round \(currentRound)"
            }
        }
    }

    /// Steps for the progress header.
    var progressSteps: [TournamentProgressStep] {
        let attendanceState: TournamentProgressStepState = hasPresentPlayers ? .complete : .current
        let seatState: TournamentProgressStepState = {
            if !hasPresentPlayers { return .upcoming }
            if hasPodsForCurrentRound { return .complete }
            return .current
        }()
        let scoreState: TournamentProgressStepState = {
            if !hasPodsForCurrentRound { return .upcoming }
            if allTablesConfirmed { return .complete }
            return .current
        }()

        return [
            TournamentProgressStep(id: "attendance", title: "Attendance", state: attendanceState),
            TournamentProgressStep(id: "seat", title: "Seat Tables", state: seatState),
            TournamentProgressStep(id: "score", title: "Score Round", state: scoreState)
        ]
    }

    /// Label for the seat-players action.
    var seatPlayersButtonTitle: String {
        "Seat Players"
    }

    /// Legacy alias for tests and tooling.
    var generatePodsButtonTitle: String {
        seatPlayersButtonTitle
    }

    var tableLayoutHint: String? {
        PodLayoutHint.message(presentCount: presentPlayerIds.count)
    }

    /// Legacy alias.
    var podLayoutHint: String? {
        tableLayoutHint
    }

    /// Whether any present player has scored points this week.
    var hasWeeklyStandingsToShow: Bool {
        weeklyStandings.contains { $0.points.total > 0 }
    }

    /// Top weekly standings rows for inline display on the Round tab.
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

    var canSeatPlayers: Bool {
        hasPresentPlayers
    }

    /// Legacy alias.
    var canGeneratePods: Bool {
        canSeatPlayers
    }
    
    var canEdit: Bool {
        !editableRounds.isEmpty
    }

    /// All scored rounds that can be corrected, including prior weeks.
    var editableRounds: [EditableRoundOption] {
        guard let tournament else { return [] }
        return tournament.podHistorySnapshots.enumerated().map { index, snapshot in
            EditableRoundOption(
                snapshotIndex: index,
                week: snapshot.week,
                round: snapshot.round,
                playerCount: snapshot.playerIds.count
            )
        }
    }

    /// Scored rounds from the current week that can be corrected.
    var editableRoundsThisWeek: [EditableRoundOption] {
        editableRounds.filter { $0.week == currentWeek }
    }

    var editableRoundsGroupedByWeek: [(week: Int, rounds: [EditableRoundOption])] {
        let grouped = Dictionary(grouping: editableRounds, by: \.week)
        return grouped.keys.sorted().map { week in
            (week: week, rounds: grouped[week]?.sorted(by: { $0.round < $1.round }) ?? [])
        }
    }

    func isPriorWeekEdit(_ option: EditableRoundOption) -> Bool {
        option.week != currentWeek
    }

    /// Whether the host can undo the most recently saved table from a prior round.
    var canUndoLastTable: Bool {
        podHistoryCount > 0
    }

    /// Whether the host can drag players between tables before scoring starts.
    var canEditSeatings: Bool {
        roundPhase == .seatingsReady
    }

    /// Rows for table-facing standings display.
    var standingsDisplayRows: [StandingsDisplayRow] {
        standingsForDisplay.enumerated().map { index, standing in
            StandingsDisplayRow(
                id: standing.player.id,
                rank: index + 1,
                name: displayName(for: standing.player),
                totalPoints: standing.totalPoints
            )
        }
    }

    var standingsDisplaySubtitle: String {
        if let week = selectedStandingsWeek {
            return "Week \(week) standings"
        }
        return "Tournament standings"
    }

    var standingsDisplayShareText: String {
        if let week = selectedStandingsWeek {
            let rows = standingsForDisplay.enumerated().map { index, standing in
                StandingsShareFormatter.WeeklyStanding(
                    rank: index + 1,
                    name: displayName(for: standing.player),
                    totalPoints: standing.totalPoints,
                    placementPoints: standing.placementPoints,
                    achievementPoints: standing.achievementPoints
                )
            }
            return StandingsShareFormatter.weeklyStandings(
                tournamentName: tournamentName,
                week: week,
                standings: rows
            )
        }

        let rows = standingsForDisplay.enumerated().map { index, standing in
            StandingsShareFormatter.TournamentStanding(
                rank: index + 1,
                name: displayName(for: standing.player),
                totalPoints: standing.totalPoints,
                placementPoints: standing.placementPoints,
                achievementPoints: standing.achievementPoints,
                wins: standing.wins ?? 0
            )
        }
        return StandingsShareFormatter.finalStandings(
            tournamentName: tournamentName,
            standings: rows
        )
    }

    var editRoundConfirmationButtonTitle: String {
        editableRounds.count == 1 ? "Edit" : "Choose Round"
    }

    var editRoundConfirmationMessage: String {
        if editableRounds.count == 1, let round = editableRounds.first {
            if isPriorWeekEdit(round) {
                return "Fix Week \(round.week) Round \(round.round). Standings will recalculate for that week."
            }
            return "Fix Week \(round.week) Round \(round.round) placements or achievements."
        }
        let count = editableRounds.count
        return "Pick one of \(count) scored rounds to fix placements or achievements. Prior weeks recalculate standings."
    }

    /// Whether the host can advance to the next round or week.
    var canNextRound: Bool {
        allTablesConfirmed
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
        
        let rows = presentPlayers.map { player in
            (player: player, points: weeklyPoints[player.id] ?? WeeklyPlayerPoints())
        }
        return StandingsRanking.sortWeeklyStandings(rows)
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
            .sorted { lhs, rhs in
                StandingsRanking.ranksHigher(
                    points: lhs.points,
                    player: lhs.player,
                    than: rhs.points,
                    player: rhs.player
                )
            }
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
            .sorted { lhs, rhs in
                StandingsRanking.ranksHigher(
                    points: lhs.points,
                    player: lhs.player,
                    than: rhs.points,
                    player: rhs.player
                )
            }
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
            return weekStandings(week: week).map {
                ($0.player, $0.points, $0.placementPoints, $0.achievementPoints, nil as Int?)
            }
        }
        return overallStandings.map {
            ($0.player, $0.points, $0.placementPoints, $0.achievementPoints, $0.wins as Int?)
        }
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

    func clearPersistenceError() {
        persistenceErrorMessage = nil
    }

    @discardableResult
    private func saveRoundChanges() -> Bool {
        guard PersistenceSave.save(context: context, event: .round) else {
            persistenceErrorMessage = PersistenceError.saveFailed.toastMessage
            return false
        }
        return true
    }
    
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
            reloadPodsFromTournament(tournament)

            // Filter to active achievements
            activeAchievements = allAchievements.filter { tournament.activeAchievementIds.contains($0.id) }
        }
    }

    /// Restores in-memory tables from persisted tournament state.
    private func reloadPodsFromTournament(_ tournament: Tournament) {
        let storedPodIds = tournament.currentRoundPodsPlayerIds
        guard !storedPodIds.isEmpty else {
            pods = []
            return
        }

        pods = storedPodIds.compactMap { podIds in
            let podPlayers = podIds.compactMap { id in allPlayers.first(where: { $0.id == id }) }
            return podPlayers.count == podIds.count ? podPlayers : nil
        }

        ensureTableScoringOrders(for: tournament)
        syncScoringTableIndex()
    }

    private func ensureTableScoringOrders(for tournament: Tournament) {
        guard !pods.isEmpty else { return }

        var orders = tournament.tableScoringOrders
        if orders.count != pods.count {
            orders = pods.map { $0.map(\.id) }
            tournament.tableScoringOrders = orders
            _ = saveRoundChanges()
        }
    }

    private func syncScoringTableIndex() {
        guard !pods.isEmpty else {
            currentScoringTableIndex = 0
            return
        }

        if let next = pods.indices.first(where: { !confirmedTableIndices.contains($0) }) {
            currentScoringTableIndex = next
        } else {
            currentScoringTableIndex = max(0, pods.count - 1)
        }
    }

    /// Routes to the tab that matches tournament progress for this week.
    private func syncActiveTab(for tournament: Tournament) {
        guard !hasUserSelectedTab else { return }

        if tournament.presentPlayerIds.isEmpty {
            activeTab = .attendance
        } else if activeTab == .attendance {
            activeTab = .round
        }
    }

    /// Records an explicit tab choice from the section picker.
    func setTab(_ tab: TournamentDetailTab, userInitiated: Bool = true) {
        if userInitiated {
            hasUserSelectedTab = true
        }
        activeTab = tab
    }

    /// Resets tab routing when a new week begins.
    func resetTabSelectionForNewWeek() {
        hasUserSelectedTab = false
        activeTab = .attendance
    }

    /// Re-randomizes table groupings for the current round.
    func reshuffleTables() {
        guard canSeatPlayers else { return }
        seatPlayers(forceRandom: true)
    }

    /// Legacy alias.
    func shufflePods() {
        reshuffleTables()
    }

    /// Undoes the last saved table from pod history.
    @discardableResult
    func undoLastTable() -> Bool {
        guard canUndoLastTable else { return false }
        guard LeagueEngine.undoLastPod(context: context) else {
            persistenceErrorMessage = PersistenceError.saveFailed.toastMessage
            return false
        }
        pods = []
        currentScoringTableIndex = 0
        refresh()
        return true
    }
    
    // MARK: - Actions: Round / Table Management
    
    /// Seats players at tables for the current round.
    func seatPlayers(forceRandom: Bool = false) {
        guard let tournament = tournament else { return }

        setAsActiveTournament()
        LeagueEngine.clearRoundData(context: context)

        let previousPlacements = tournament.podHistorySnapshots.last?.placements ?? [:]

        pods = LeagueEngine.generatePodsForRound(
            players: allPlayers,
            presentPlayerIds: presentPlayerIds,
            currentRound: currentRound,
            standingsBasedSeating: tournament.standingsBasedSeating,
            previousRoundPlacements: previousPlacements,
            forceRandom: forceRandom
        )

        tournament.currentRoundPodsPlayerIds = pods.map { $0.map(\.id) }
        tournament.tableScoringOrders = pods.map { $0.map(\.id) }
        tournament.roundScoringStarted = false
        currentScoringTableIndex = 0

        guard saveRoundChanges() else { return }
        refresh()
    }

    /// Legacy alias.
    func generatePods() {
        seatPlayers()
    }

    /// Begins scoring tables after the host reviews seatings.
    func startScoring() {
        guard let tournament = tournament, !pods.isEmpty else { return }
        tournament.roundScoringStarted = true
        syncScoringTableIndex()
        _ = saveRoundChanges()
    }

    func isTableConfirmed(_ index: Int) -> Bool {
        confirmedTableIndices.contains(index)
    }

    func playersForTable(at index: Int) -> [Player] {
        guard index >= 0, index < pods.count else { return [] }
        let order = tournament?.tableScoringOrders[safe: index] ?? pods[index].map(\.id)
        return order.compactMap { id in allPlayers.first(where: { $0.id == id }) }
    }

    func movePlayerInTable(at tableIndex: Int, from source: Int, to destination: Int) {
        guard let tournament,
              tableIndex >= 0,
              tableIndex < pods.count,
              source != destination,
              source >= 0,
              destination >= 0 else { return }

        var orders = tournament.tableScoringOrders
        if orders.count != pods.count {
            orders = pods.map { $0.map(\.id) }
        }

        var order = orders[tableIndex]
        guard source < order.count, destination < order.count else { return }

        let playerId = order.remove(at: source)
        order.insert(playerId, at: destination)
        orders[tableIndex] = order
        tournament.tableScoringOrders = orders
        guard saveRoundChanges() else { return }
        refresh()
    }

    func movePlayerUp(inTable tableIndex: Int, at playerIndex: Int) {
        guard playerIndex > 0 else { return }
        movePlayerInTable(at: tableIndex, from: playerIndex, to: playerIndex - 1)
    }

    func movePlayerDown(inTable tableIndex: Int, at playerIndex: Int) {
        let players = playersForTable(at: tableIndex)
        guard playerIndex < players.count - 1 else { return }
        movePlayerInTable(at: tableIndex, from: playerIndex, to: playerIndex + 1)
    }

    func selectScoringTable(_ index: Int) {
        guard index >= 0, index < pods.count else { return }
        currentScoringTableIndex = index
    }

    /// Saves placements for a table and marks it confirmed.
    func confirmTable(at index: Int) {
        guard let tournament = tournament,
              index >= 0,
              index < pods.count else { return }

        let playerIds = tournament.tableScoringOrders[safe: index] ?? pods[index].map(\.id)
        for (placeIndex, playerId) in playerIds.enumerated() {
            LeagueEngine.updatePlacement(context: context, playerId: playerId, placement: placeIndex + 1)
        }

        var confirmed = tournament.confirmedTableIndices
        confirmed.insert(index)
        tournament.confirmedTableIndices = confirmed

        guard saveRoundChanges() else { return }
        refresh()

        if let next = pods.indices.first(where: { !confirmedTableIndices.contains($0) }) {
            currentScoringTableIndex = next
        }
    }

    /// Confirms every table for the current round (used in tests and tooling).
    func confirmAllTables() {
        for index in pods.indices where !confirmedTableIndices.contains(index) {
            confirmTable(at: index)
        }
    }

    func placementLabel(for place: Int) -> String {
        switch place {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(place)"
        }
    }

    func placementSummary(forTable index: Int) -> [(name: String, place: Int)] {
        playersForTable(at: index).enumerated().map { offset, player in
            let place = placement(for: player.id) ?? (offset + 1)
            return (displayName(for: player), place)
        }
    }
    
    /// Sets placement for a player (auto-saves immediately).
    func setPlacement(for playerId: String, place: Int) {
        LeagueEngine.updatePlacement(context: context, playerId: playerId, placement: place)
    }
    
    /// Returns placement for a player when recorded for the current round.
    func placement(for playerId: String) -> Int? {
        guard let tournament = tournament else { return nil }
        return tournament.roundPlacements[playerId]
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
    
    /// Moves a player from one table to another before scoring begins.
    func movePlayer(_ playerId: String, fromTable: Int, toTable: Int) {
        guard canEditSeatings,
              let tournament,
              fromTable != toTable,
              fromTable >= 0,
              toTable >= 0,
              fromTable < pods.count,
              toTable < pods.count,
              let playerIndex = pods[fromTable].firstIndex(where: { $0.id == playerId }) else { return }

        let player = pods[fromTable].remove(at: playerIndex)
        pods[toTable].append(player)

        tournament.currentRoundPodsPlayerIds = pods.map { $0.map(\.id) }
        tournament.tableScoringOrders = pods.map { $0.map(\.id) }
        guard saveRoundChanges() else { return }
        refresh()
    }

    /// Opens the edit sheet for a specific scored round snapshot.
    func editRound(snapshotIndex: Int) {
        editSnapshotIndex = snapshotIndex
        showEditLastRound = true
    }

    /// Legacy entry point — edits the most recent scored round.
    func editLastRound() {
        editSnapshotIndex = nil
        showEditLastRound = true
    }
    
    /// Called when the edit last round view saves changes.
    func onEditLastRoundSaved() {
        editSnapshotIndex = nil
        if let tournament {
            LeagueEngine.clearTransientRoundState(on: tournament)
            guard saveRoundChanges() else { return }
        }
        pods = []
        currentScoringTableIndex = 0
        refresh()
    }
    
    /// Advances to the next round or next week.
    func nextRound() {
        let endingWeek = currentWeek
        let isEndOfWeek = currentRound >= AppConstants.League.roundsPerWeek
        let wasFinalWeek = tournament?.isFinalWeek ?? false

        guard LeagueEngine.nextRound(context: context) else {
            persistenceErrorMessage = PersistenceError.saveFailed.toastMessage
            return
        }
        pods = []
        currentScoringTableIndex = 0
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
        resetTabSelectionForNewWeek()
    }

    /// Returns to table scoring from the review step, clearing saved placements for this round.
    func reopenScoring() {
        guard let tournament else { return }
        tournament.confirmedTableIndices = []
        tournament.roundPlacements = [:]
        tournament.roundAchievementChecks = []
        tournament.roundScoringStarted = true
        currentScoringTableIndex = 0
        guard saveRoundChanges() else { return }
        refresh()
    }
    
    // MARK: - Actions: Navigation
    
    /// Sets this tournament as the active tournament.
    func setAsActiveTournament() {
        guard let state = LeagueEngine.fetchLeagueState(context: context) else { return }
        state.activeTournamentId = tournamentId
        _ = PersistenceSave.save(context: context, event: .tournament)
    }
    
    /// Switches to the Attendance tab to edit who's present this week.
    func goToAttendance() {
        setAsActiveTournament()
        setTab(.attendance)
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: allPlayers)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
