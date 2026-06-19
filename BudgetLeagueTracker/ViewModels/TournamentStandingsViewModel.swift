import Foundation
import SwiftData

/// ViewModel for the Tournament Standings view.
/// Shows players ranked by points earned in this tournament only.
@MainActor
@Observable
final class TournamentStandingsViewModel {
    private let context: ModelContext
    
    // MARK: - Published State
    
    var standings: [(player: Player, totalPoints: Int, placementPoints: Int, achievementPoints: Int, wins: Int)] = []
    var isFinal: Bool = false
    var tournamentName: String = ""

    private var roster: [Player] = []
    private var tournamentId: String?
    
    // MARK: - Initialization
    
    init(context: ModelContext) {
        self.context = context
        refresh()
    }
    
    // MARK: - Actions
    
    /// Refreshes state from SwiftData.
    func refresh() {
        let descriptor = FetchDescriptor<Player>()
        roster = (try? context.fetch(descriptor)) ?? []

        guard let tournament = resolveTournament() else {
            standings = []
            return
        }

        tournamentId = tournament.id
        isFinal = tournament.isFinalWeek || tournament.status == .completed
        tournamentName = tournament.name

        let results = StatsEngine.fetchResultsForTournament(tournament.id, context: context)
        var stats: [String: (points: Int, placementPoints: Int, achievementPoints: Int, wins: Int)] = [:]
        for result in results {
            let current = stats[result.playerId] ?? (0, 0, 0, 0)
            stats[result.playerId] = (
                points: current.points + result.totalPoints,
                placementPoints: current.placementPoints + result.placementPoints,
                achievementPoints: current.achievementPoints + result.achievementPoints,
                wins: current.wins + (result.isWin ? 1 : 0)
            )
        }

        standings = stats
            .compactMap { playerId, row -> (player: Player, totalPoints: Int, placementPoints: Int, achievementPoints: Int, wins: Int)? in
                guard let player = roster.first(where: { $0.id == playerId }) else { return nil }
                return (player, row.points, row.placementPoints, row.achievementPoints, row.wins)
            }
            .sorted { lhs, rhs in
                StandingsRanking.ranksHigher(
                    points: lhs.totalPoints,
                    player: lhs.player,
                    than: rhs.totalPoints,
                    player: rhs.player
                )
            }
    }
    
    /// Closes tournament standings and returns to tournaments list.
    func close() {
        LeagueEngine.closeTournamentStandings(context: context)
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: roster)
    }

    private func resolveTournament() -> Tournament? {
        if let tournament = LeagueEngine.fetchActiveTournament(context: context) {
            return tournament
        }
        if let state = LeagueEngine.fetchLeagueState(context: context),
           let id = state.activeTournamentId {
            return LeagueEngine.fetchTournament(context: context, id: id)
        }
        return nil
    }
}
