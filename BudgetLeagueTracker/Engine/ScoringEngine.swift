import Foundation
import SwiftData

/// Round scoring persistence helpers extracted from LeagueEngine.
enum ScoringEngine {
    @discardableResult
    static func updatePlacement(context: ModelContext, playerId: String, placement: Int) -> Bool {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return false }

        var placements = tournament.roundPlacements
        placements[playerId] = placement
        tournament.roundPlacements = placements

        return PersistenceSave.save(context: context, event: .round)
    }

    @discardableResult
    static func updateAchievementCheck(
        context: ModelContext,
        playerId: String,
        achievementId: String,
        checked: Bool,
        podPlayerIds: [String]? = nil
    ) -> Bool {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return false }

        let key = "\(playerId):\(achievementId)"
        var checks = tournament.roundAchievementChecks

        if checked {
            if let achievement = LeagueEngine.fetchAchievement(context: context, id: achievementId),
               achievement.exclusivity == .onePerPod,
               let podPlayerIds {
                for otherPlayerId in podPlayerIds where otherPlayerId != playerId {
                    checks.remove("\(otherPlayerId):\(achievementId)")
                }
            }
            checks.insert(key)
        } else {
            checks.remove(key)
        }

        tournament.roundAchievementChecks = checks
        return PersistenceSave.save(context: context, event: .round)
    }
}
