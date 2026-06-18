import Foundation

/// Deterministic ordering for standings and winner selection.
///
/// Tie order: points descending, then player name (case-insensitive), then player id.
/// Dictionary iteration and bare `max(by:)` on keys are not stable without this.
enum StandingsRanking {
    /// Returns true when `lhs` should appear above `rhs` in a standings list.
    static func ranksHigher(
        points lhsPoints: Int,
        player lhs: Player,
        than rhsPoints: Int,
        player rhs: Player
    ) -> Bool {
        if lhsPoints != rhsPoints { return lhsPoints > rhsPoints }
        let nameOrder = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
        if nameOrder != .orderedSame { return nameOrder == .orderedAscending }
        return lhs.id < rhs.id
    }

    static func sortByPointsDescending<T>(
        _ items: [T],
        points: (T) -> Int,
        player: (T) -> Player
    ) -> [T] {
        items.sorted {
            ranksHigher(
                points: points($0),
                player: player($0),
                than: points($1),
                player: player($1)
            )
        }
    }

    static func sortWeeklyStandings(
        _ items: [(player: Player, points: WeeklyPlayerPoints)]
    ) -> [(player: Player, points: WeeklyPlayerPoints)] {
        sortByPointsDescending(items, points: { $0.points.total }, player: { $0.player })
    }

    static func sortByTotalPoints(
        _ items: [(player: Player, totalPoints: Int)]
    ) -> [(player: Player, totalPoints: Int)] {
        sortByPointsDescending(items, points: { $0.totalPoints }, player: { $0.player })
    }

    /// Highest-ranked player among those with entries in `pointsByPlayer`.
    static func winnerPlayer(from pointsByPlayer: [String: Int], among players: [Player]) -> Player? {
        players
            .filter { pointsByPlayer[$0.id] != nil }
            .max { lhs, rhs in
                !ranksHigher(
                    points: pointsByPlayer[lhs.id] ?? 0,
                    player: lhs,
                    than: pointsByPlayer[rhs.id] ?? 0,
                    player: rhs
                )
            }
    }
}
