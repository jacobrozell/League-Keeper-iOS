import Foundation
import SwiftData

/// Round scoring persistence and finalization extracted from LeagueEngine.
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
        tablePlayerIds: [String]? = nil
    ) -> Bool {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return false }

        let key = "\(playerId):\(achievementId)"
        var checks = tournament.roundAchievementChecks

        if checked {
            if let achievement = LeagueEngine.fetchAchievement(context: context, id: achievementId),
               achievement.exclusivity == .onePerPod,
               let tablePlayerIds {
                for otherPlayerId in tablePlayerIds where otherPlayerId != playerId {
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

    /// Finalizes the current round's placements and achievements.
    @discardableResult
    static func finalizeRound(context: ModelContext) -> Bool {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return false }

        let placements = tournament.roundPlacements
        let achievementCheckKeys = tournament.roundAchievementChecks

        guard !placements.isEmpty else { return false }

        let playerDescriptor = FetchDescriptor<Player>()
        guard let allPlayers = try? context.fetch(playerDescriptor) else { return false }

        let achievementDescriptor = FetchDescriptor<Achievement>()
        let allAchievements = (try? context.fetch(achievementDescriptor)) ?? []
        let achievementLookup = Dictionary(uniqueKeysWithValues: allAchievements.map { ($0.id, $0) })

        var playerDeltas: [String: PlayerDelta] = [:]
        var weeklyDeltas: [String: WeeklyPlayerPoints] = [:]
        var checkRecords: [AchievementCheck] = []

        let roundPodGroups = tournament.currentRoundPodsPlayerIds
        let podIdByPlayer = podIds(forPlacements: placements, podGroups: roundPodGroups)
        let placementScale = tournament.placementPointsScale

        for (playerId, place) in placements {
            let placementPts = AppConstants.Scoring.placementPoints(forPlace: place, scale: placementScale)

            var achievementPts = 0
            var earnedAchievementIds: [String] = []

            if tournament.achievementsOnThisWeek {
                for key in achievementCheckKeys where key.hasPrefix("\(playerId):") {
                    let achievementId = String(key.dropFirst(playerId.count + 1))
                    if let achievement = achievementLookup[achievementId] {
                        achievementPts += achievement.points
                        earnedAchievementIds.append(achievementId)
                        checkRecords.append(AchievementCheck(
                            playerId: playerId,
                            achievementId: achievementId,
                            points: achievement.points
                        ))
                    }
                }
            }

            let isWin = place == 1

            playerDeltas[playerId] = PlayerDelta(
                placementPoints: placementPts,
                achievementPoints: achievementPts,
                wins: isWin ? 1 : 0,
                gamesPlayed: 1
            )
            weeklyDeltas[playerId] = WeeklyPlayerPoints(
                placementPoints: placementPts,
                achievementPoints: achievementPts
            )

            let gameResult = GameResult(
                tournamentId: tournament.id,
                week: tournament.currentWeek,
                round: tournament.currentRound,
                playerId: playerId,
                placement: place,
                placementPoints: placementPts,
                achievementPoints: achievementPts,
                achievementIds: earnedAchievementIds,
                podId: podIdByPlayer[playerId] ?? UUID().uuidString
            )
            context.insert(gameResult)
        }

        for player in allPlayers {
            if let delta = playerDeltas[player.id] {
                player.placementPoints += delta.placementPoints
                player.achievementPoints += delta.achievementPoints
                player.wins += delta.wins
                player.gamesPlayed += delta.gamesPlayed
            }
        }

        var weeklyPoints = tournament.weeklyPointsByPlayer
        for (playerId, delta) in weeklyDeltas {
            var current = weeklyPoints[playerId] ?? WeeklyPlayerPoints()
            current.placementPoints += delta.placementPoints
            current.achievementPoints += delta.achievementPoints
            weeklyPoints[playerId] = current
        }
        tournament.weeklyPointsByPlayer = weeklyPoints

        var snapshots = tournament.podHistorySnapshots
        snapshots.append(PodSnapshot(
            week: tournament.currentWeek,
            round: tournament.currentRound,
            playerIds: Array(placements.keys),
            placements: placements,
            achievementChecks: checkRecords,
            playerDeltas: playerDeltas,
            weeklyDeltas: weeklyDeltas
        ))
        tournament.podHistorySnapshots = snapshots

        clearTransientRoundState(on: tournament)

        return PersistenceSave.save(context: context, event: .round)
    }

    /// Undoes the last finalized table round.
    @discardableResult
    static func undoLastPod(context: ModelContext) -> Bool {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return false }

        var snapshots = tournament.podHistorySnapshots
        guard let lastSnapshot = snapshots.popLast() else { return true }

        let playerDescriptor = FetchDescriptor<Player>()
        if let allPlayers = try? context.fetch(playerDescriptor) {
            for player in allPlayers {
                if let delta = lastSnapshot.playerDeltas[player.id] {
                    player.placementPoints -= delta.placementPoints
                    player.achievementPoints -= delta.achievementPoints
                    player.wins -= delta.wins
                    player.gamesPlayed -= delta.gamesPlayed
                }
            }
        }

        var weeklyPoints = tournament.weeklyPointsByPlayer
        for (playerId, delta) in lastSnapshot.weeklyDeltas {
            var current = weeklyPoints[playerId] ?? WeeklyPlayerPoints()
            current.placementPoints -= delta.placementPoints
            current.achievementPoints -= delta.achievementPoints
            weeklyPoints[playerId] = current
        }
        tournament.weeklyPointsByPlayer = weeklyPoints

        tournament.podHistorySnapshots = snapshots

        let gameResultDescriptor = FetchDescriptor<GameResult>()
        if let allResults = try? context.fetch(gameResultDescriptor) {
            for playerId in lastSnapshot.playerIds {
                let matchingResults = allResults.filter {
                    $0.tournamentId == tournament.id &&
                    $0.week == lastSnapshot.week &&
                    $0.round == lastSnapshot.round &&
                    $0.playerId == playerId
                }
                for result in matchingResults {
                    context.delete(result)
                }
            }
        }

        return PersistenceSave.save(context: context, event: .round)
    }

    /// Applies edited round data, replacing a snapshot with updated values.
    @discardableResult
    static func applyEditedRound(
        context: ModelContext,
        snapshotIndex: Int? = nil,
        newPlacements: [String: Int],
        newAchievementChecks: Set<String>
    ) -> Bool {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return false }

        var snapshots = tournament.podHistorySnapshots
        let index: Int
        if let snapshotIndex {
            guard snapshots.indices.contains(snapshotIndex) else { return false }
            index = snapshotIndex
        } else {
            guard let lastIndex = snapshots.indices.last else { return false }
            index = lastIndex
        }

        let lastSnapshot = snapshots.remove(at: index)
        let editWeek = lastSnapshot.week
        let editRound = lastSnapshot.round

        let playerDescriptor = FetchDescriptor<Player>()
        guard let allPlayers = try? context.fetch(playerDescriptor) else { return false }

        let achievementDescriptor = FetchDescriptor<Achievement>()
        let allAchievements = (try? context.fetch(achievementDescriptor)) ?? []
        let achievementLookup = Dictionary(uniqueKeysWithValues: allAchievements.map { ($0.id, $0) })

        for player in allPlayers {
            if let delta = lastSnapshot.playerDeltas[player.id] {
                player.placementPoints -= delta.placementPoints
                player.achievementPoints -= delta.achievementPoints
                player.wins -= delta.wins
                player.gamesPlayed -= delta.gamesPlayed
            }
        }

        var weeklyPoints = tournament.weeklyPointsByPlayer
        for (playerId, delta) in lastSnapshot.weeklyDeltas {
            var current = weeklyPoints[playerId] ?? WeeklyPlayerPoints()
            current.placementPoints -= delta.placementPoints
            current.achievementPoints -= delta.achievementPoints
            weeklyPoints[playerId] = current
        }

        var newPlayerDeltas: [String: PlayerDelta] = [:]
        var newWeeklyDeltas: [String: WeeklyPlayerPoints] = [:]
        var newCheckRecords: [AchievementCheck] = []
        let placementScale = tournament.placementPointsScale

        for (playerId, place) in newPlacements {
            let placementPts = AppConstants.Scoring.placementPoints(forPlace: place, scale: placementScale)

            var achievementPts = 0

            if tournament.achievementsOnThisWeek {
                for key in newAchievementChecks where key.hasPrefix("\(playerId):") {
                    let achievementId = String(key.dropFirst(playerId.count + 1))
                    if let achievement = achievementLookup[achievementId] {
                        achievementPts += achievement.points
                        newCheckRecords.append(AchievementCheck(
                            playerId: playerId,
                            achievementId: achievementId,
                            points: achievement.points
                        ))
                    }
                }
            }

            let isWin = place == 1

            newPlayerDeltas[playerId] = PlayerDelta(
                placementPoints: placementPts,
                achievementPoints: achievementPts,
                wins: isWin ? 1 : 0,
                gamesPlayed: 1
            )
            newWeeklyDeltas[playerId] = WeeklyPlayerPoints(
                placementPoints: placementPts,
                achievementPoints: achievementPts
            )
        }

        for player in allPlayers {
            if let delta = newPlayerDeltas[player.id] {
                player.placementPoints += delta.placementPoints
                player.achievementPoints += delta.achievementPoints
                player.wins += delta.wins
                player.gamesPlayed += delta.gamesPlayed
            }
        }

        for (playerId, delta) in newWeeklyDeltas {
            var current = weeklyPoints[playerId] ?? WeeklyPlayerPoints()
            current.placementPoints += delta.placementPoints
            current.achievementPoints += delta.achievementPoints
            weeklyPoints[playerId] = current
        }
        tournament.weeklyPointsByPlayer = weeklyPoints

        var existingPodIdByPlayer: [String: String] = [:]
        let gameResultDescriptor = FetchDescriptor<GameResult>()
        if let allResults = try? context.fetch(gameResultDescriptor) {
            for playerId in lastSnapshot.playerIds {
                let matchingResults = allResults.filter {
                    $0.tournamentId == tournament.id &&
                    $0.week == editWeek &&
                    $0.round == editRound &&
                    $0.playerId == playerId
                }
                if let podId = matchingResults.first?.podId {
                    existingPodIdByPlayer[playerId] = podId
                }
                for result in matchingResults {
                    context.delete(result)
                }
            }
        }

        let fallbackPodId = UUID().uuidString
        for (playerId, place) in newPlacements {
            let delta = newPlayerDeltas[playerId]!
            let earnedAchievementIds = newCheckRecords
                .filter { $0.playerId == playerId }
                .map { $0.achievementId }

            let gameResult = GameResult(
                tournamentId: tournament.id,
                week: editWeek,
                round: editRound,
                playerId: playerId,
                placement: place,
                placementPoints: delta.placementPoints,
                achievementPoints: delta.achievementPoints,
                achievementIds: earnedAchievementIds,
                podId: existingPodIdByPlayer[playerId] ?? fallbackPodId
            )
            context.insert(gameResult)
        }

        let newSnapshot = PodSnapshot(
            week: editWeek,
            round: editRound,
            playerIds: Array(newPlacements.keys),
            placements: newPlacements,
            achievementChecks: newCheckRecords,
            playerDeltas: newPlayerDeltas,
            weeklyDeltas: newWeeklyDeltas
        )
        snapshots.insert(newSnapshot, at: index)
        tournament.podHistorySnapshots = snapshots

        return PersistenceSave.save(context: context, event: .round)
    }

    /// Resets in-progress round scoring state without touching pod history.
    static func clearTransientRoundState(on tournament: Tournament) {
        tournament.roundPlacements = [:]
        tournament.roundAchievementChecks = []
        tournament.currentRoundPodsPlayerIds = []
        tournament.confirmedTableIndices = []
        tournament.tableScoringOrders = []
        tournament.roundScoringStarted = false
    }

    private static func podIds(
        forPlacements placements: [String: Int],
        podGroups: [[String]]
    ) -> [String: String] {
        var podIdByPlayer: [String: String] = [:]
        for group in podGroups {
            let groupPodId = UUID().uuidString
            for playerId in group {
                podIdByPlayer[playerId] = groupPodId
            }
        }
        let uncovered = placements.keys.filter { podIdByPlayer[$0] == nil }
        if !uncovered.isEmpty {
            let fallbackPodId = UUID().uuidString
            for playerId in uncovered {
                podIdByPlayer[playerId] = fallbackPodId
            }
        }
        return podIdByPlayer
    }
}
