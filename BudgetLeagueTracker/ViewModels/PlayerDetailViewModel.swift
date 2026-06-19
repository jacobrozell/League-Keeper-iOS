import Foundation
import SwiftData

/// ViewModel for the Player Detail view.
/// Provides comprehensive player statistics and handles player deletion.
@MainActor
@Observable
final class PlayerDetailViewModel {
    private let context: ModelContext

    // MARK: - Published State

    var player: Player
    var allPlayers: [Player] = []
    var gameResults: [GameResult] = []
    var achievements: [Achievement] = []
    var tournaments: [Tournament] = []
    var recentRounds: [PlayerRoundSummary] = []
    var attendanceSummaries: [PlayerAttendanceSummary] = []
    var selectedScope: PlayerDetailScope = .allTime
    var headToHeadOpponentId: String?
    var selectedRoundDetail: PlayerRoundDetail?
    var showRoundDetail: Bool = false
    var showEditNameSheet: Bool = false
    var showDeleteConfirmation: Bool = false

    // MARK: - Scoped Data

    var scopedResults: [GameResult] {
        switch selectedScope {
        case .allTime:
            return gameResults.filter { $0.playerId == player.id }
        case .tournament(let id, _):
            return gameResults.filter { $0.playerId == player.id && $0.tournamentId == id }
        }
    }

    var scopedTournamentStats: TournamentPlayerStats? {
        guard case .tournament(let id, _) = selectedScope else { return nil }
        return StatsEngine.tournamentStats(
            playerId: player.id,
            tournamentId: id,
            results: gameResults
        )
    }

    // MARK: - Display Stats

    var displayTotalPoints: Int {
        if let stats = scopedTournamentStats { return stats.totalPoints }
        return player.totalPoints
    }

    var displayGamesPlayed: Int {
        if let stats = scopedTournamentStats { return stats.gamesPlayed }
        return player.gamesPlayed
    }

    var displayWins: Int {
        if let stats = scopedTournamentStats { return stats.wins }
        return player.wins
    }

    var displayTournamentsPlayed: Int {
        switch selectedScope {
        case .allTime: return player.tournamentsPlayed
        case .tournament: return (scopedTournamentStats?.gamesPlayed ?? 0) > 0 ? 1 : 0
        }
    }

    var winRatePercentage: Double {
        if let stats = scopedTournamentStats { return stats.winRate * 100 }
        return StatsEngine.winRate(for: player) * 100
    }

    var winRateString: String {
        String(format: "%.1f%%", winRatePercentage)
    }

    var averagePlacement: Double {
        if let stats = scopedTournamentStats, stats.gamesPlayed > 0 {
            return stats.averagePlacement
        }
        return StatsEngine.averagePlacement(playerId: player.id, results: scopedResults)
    }

    var averagePlacementString: String {
        averagePlacement > 0 ? String(format: "%.2f", averagePlacement) : "N/A"
    }

    var displayPlacementPoints: Int {
        if let stats = scopedTournamentStats { return stats.placementPoints }
        return player.placementPoints
    }

    var displayAchievementPoints: Int {
        if let stats = scopedTournamentStats { return stats.achievementPoints }
        return player.achievementPoints
    }

    var pointsPerGame: Double {
        let games = displayGamesPlayed
        guard games > 0 else { return 0 }
        return Double(displayTotalPoints) / Double(games)
    }

    var pointsPerGameString: String {
        String(format: "%.1f", pointsPerGame)
    }

    var placementDistribution: [PlacementData] {
        let distribution = StatsEngine.placementDistribution(playerId: player.id, results: scopedResults)
        return PlacementData.from(distribution: distribution)
    }

    var performanceTrend: [PerformanceTrendData] {
        let playerResults = scopedResults
            .sorted { $0.week < $1.week || ($0.week == $1.week && $0.round < $1.round) }

        var cumulativePoints = 0
        var cumulativePlacement = 0
        var cumulativeAchievement = 0
        var weeklyData: [Int: PerformanceTrendData] = [:]

        for result in playerResults {
            cumulativePoints += result.totalPoints
            cumulativePlacement += result.placementPoints
            cumulativeAchievement += result.achievementPoints

            weeklyData[result.week] = PerformanceTrendData(
                id: "\(player.id)-\(result.week)",
                playerName: displayName,
                week: result.week,
                cumulativePoints: cumulativePoints,
                placementPoints: cumulativePlacement,
                achievementPoints: cumulativeAchievement
            )
        }

        return weeklyData.values.sorted { $0.week < $1.week }
    }

    var hasGameResults: Bool {
        !scopedResults.isEmpty
    }

    var lastPlayedText: String? {
        guard let latest = scopedRecentRounds.first ?? recentRounds.first else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Last played \(formatter.localizedString(for: latest.timestamp, relativeTo: Date()))"
    }

    var overallAttendanceText: String? {
        let totalWeeks = attendanceSummaries.reduce(0) { $0 + $1.weeksTotal }
        guard totalWeeks > 0 else { return nil }
        let presentWeeks = attendanceSummaries.reduce(0) { $0 + $1.weeksPresent }
        let percentage = Int((Double(presentWeeks) / Double(totalWeeks) * 100).rounded())
        return "\(presentWeeks) of \(totalWeeks) weeks attended (\(percentage)%)"
    }

    var overallAttendanceFraction: Double {
        let totalWeeks = attendanceSummaries.reduce(0) { $0 + $1.weeksTotal }
        guard totalWeeks > 0 else { return 0 }
        let presentWeeks = attendanceSummaries.reduce(0) { $0 + $1.weeksPresent }
        return Double(presentWeeks) / Double(totalWeeks)
    }

    var leagueRank: Int? {
        StatsEngine.leagueRanks(players: allPlayers)[player.id]
    }

    var formHighlightText: String? {
        StatsEngine.playerFormHighlights(playerId: player.id, results: scopedResults).displayText
    }

    var displayName: String {
        PlayerDisambiguation.displayName(for: player, among: allPlayers)
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: allPlayers)
    }

    var availableScopes: [PlayerDetailScope] {
        var scopes: [PlayerDetailScope] = [.allTime]
        let tournamentIds = Set(gameResults.filter { $0.playerId == player.id }.map(\.tournamentId))
        let scopedTournaments = tournaments
            .filter { tournamentIds.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        scopes.append(contentsOf: scopedTournaments.map { .tournament(id: $0.id, name: $0.name) })
        return scopes
    }

    var scopedRecentRounds: [PlayerRoundSummary] {
        switch selectedScope {
        case .allTime:
            return recentRounds
        case .tournament(let id, _):
            return recentRounds.filter { $0.tournamentId == id }
        }
    }

    var achievementGallery: [(achievement: Achievement, timesEarned: Int)] {
        AchievementStatsEngine.playerAchievementHistory(
            playerId: player.id,
            achievements: achievements,
            results: scopedResults
        )
    }

    var headToHeadOpponents: [Player] {
        allPlayers
            .filter { $0.id != player.id }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var headToHeadRecord: HeadToHeadRecord? {
        guard let opponentId = headToHeadOpponentId else { return nil }
        return StatsEngine.headToHeadRecord(
            player1Id: player.id,
            player2Id: opponentId,
            results: gameResults
        )
    }

    var headToHeadOpponentName: String? {
        guard let opponentId = headToHeadOpponentId else { return nil }
        guard let opponent = allPlayers.first(where: { $0.id == opponentId }) else { return nil }
        return displayName(for: opponent)
    }

    var statsSectionTitle: String {
        switch selectedScope {
        case .allTime: return "All-Time Stats"
        case .tournament(_, let name): return "\(name) Stats"
        }
    }

    // MARK: - Initialization

    init(context: ModelContext, player: Player) {
        self.context = context
        self.player = player
        refresh()
    }

    // MARK: - Actions

    func refresh() {
        let playerDescriptor = FetchDescriptor<Player>()
        if let players = try? context.fetch(playerDescriptor) {
            allPlayers = players
            if let updatedPlayer = players.first(where: { $0.id == player.id }) {
                player = updatedPlayer
            }
        }

        let achievementDescriptor = FetchDescriptor<Achievement>()
        achievements = (try? context.fetch(achievementDescriptor)) ?? []

        gameResults = StatsEngine.fetchAllResults(context: context)
        tournaments = StatsEngine.fetchAllTournaments(context: context)
        recentRounds = StatsEngine.recentRoundSummaries(
            playerId: player.id,
            results: gameResults,
            tournaments: tournaments
        )
        attendanceSummaries = StatsEngine.attendanceSummaries(
            playerId: player.id,
            tournaments: tournaments,
            results: gameResults
        )
    }

    func selectRound(_ round: PlayerRoundSummary) {
        selectedRoundDetail = StatsEngine.roundDetail(
            resultId: round.id,
            playerId: player.id,
            results: gameResults,
            players: allPlayers,
            achievements: achievements,
            tournaments: tournaments
        )
        showRoundDetail = selectedRoundDetail != nil
    }

    enum NameUpdateResult {
        case success
        case failure(String)
    }

    func updatePlayer(name: String, nameNote: String) -> NameUpdateResult {
        let trimmedNote = nameNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = LeagueEngine.updatePlayer(
            context: context,
            id: player.id,
            name: name,
            nameNote: trimmedNote.isEmpty ? nil : trimmedNote
        ) {
            return .failure(error)
        }
        refresh()
        return .success
    }

    func updateName(_ name: String) -> NameUpdateResult {
        updatePlayer(name: name, nameNote: player.nameNote ?? "")
    }

    func confirmDelete() {
        showDeleteConfirmation = true
    }

    func deletePlayer() -> Bool {
        LeagueEngine.removePlayer(context: context, id: player.id)
    }
}
