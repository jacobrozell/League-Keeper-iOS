import Testing
import SwiftData
import Foundation
@testable import BudgetLeagueTracker

/// Integration tests for pod identity and edit/undo correctness.
///
/// These cover two regressions:
///  1. A round with more than one pod must assign a distinct pod ID per pod, so
///     head-to-head records only pair players who actually shared a pod.
///  2. Editing/undoing the last round must target the round's original
///     GameResults even after the tournament has advanced to a later round.
@Suite("Pod Integrity Integration Tests", .serialized)
@MainActor
struct PodIntegrityTests {

    // MARK: - Multi-pod pod IDs

    @Test("Two pods in one round get distinct pod IDs")
    func twoPodsGetDistinctPodIds() async throws {
        let context = try TestHelpers.bootstrappedContext()
        let players = TestFixtures.players("A", "B", "C", "D", "E", "F", "G", "H")
        for player in players { context.insert(player) }
        try context.save()

        LeagueEngine.createTournament(
            context: context,
            name: "Two Pods",
            totalWeeks: 1,
            randomPerWeek: 0,
            playerIds: players.map { $0.id }
        )
        LeagueEngine.confirmAttendance(
            context: context,
            presentIds: players.map { $0.id },
            achievementsOnThisWeek: false
        )

        // Record two explicit pods of 4 (mirrors what the view model does after
        // generating pods), then place everyone.
        let podA = Array(players.prefix(4))
        let podB = Array(players.suffix(4))
        LeagueEngine.recordRoundPods(
            context: context,
            pods: [podA.map { $0.id }, podB.map { $0.id }]
        )
        for pod in [podA, podB] {
            for (index, player) in pod.enumerated() {
                LeagueEngine.updatePlacement(context: context, playerId: player.id, placement: index + 1)
            }
        }

        LeagueEngine.finalizeRound(context: context)

        let results = try TestHelpers.fetchAll(GameResult.self, from: context)
        #expect(results.count == 8)

        // Exactly two distinct pod IDs, one per pod of four.
        let podIds = Set(results.map { $0.podId })
        #expect(podIds.count == 2)

        let podAIds = Set(results.filter { r in podA.contains { $0.id == r.playerId } }.map { $0.podId })
        let podBIds = Set(results.filter { r in podB.contains { $0.id == r.playerId } }.map { $0.podId })
        #expect(podAIds.count == 1)
        #expect(podBIds.count == 1)
        #expect(podAIds.isDisjoint(with: podBIds))
    }

    @Test("Players in different pods are not counted as head-to-head opponents")
    func differentPodsNoHeadToHead() async throws {
        let context = try TestHelpers.bootstrappedContext()
        let players = TestFixtures.players("A", "B", "C", "D", "E", "F", "G", "H")
        for player in players { context.insert(player) }
        try context.save()

        LeagueEngine.createTournament(
            context: context,
            name: "H2H Pods",
            totalWeeks: 1,
            randomPerWeek: 0,
            playerIds: players.map { $0.id }
        )
        LeagueEngine.confirmAttendance(
            context: context,
            presentIds: players.map { $0.id },
            achievementsOnThisWeek: false
        )

        let podA = Array(players.prefix(4)) // A, B, C, D
        let podB = Array(players.suffix(4)) // E, F, G, H
        LeagueEngine.recordRoundPods(
            context: context,
            pods: [podA.map { $0.id }, podB.map { $0.id }]
        )
        for pod in [podA, podB] {
            for (index, player) in pod.enumerated() {
                LeagueEngine.updatePlacement(context: context, playerId: player.id, placement: index + 1)
            }
        }
        LeagueEngine.finalizeRound(context: context)

        let results = try TestHelpers.fetchAll(GameResult.self, from: context)

        // A (pod A) vs E (pod B) never shared a pod -> no games.
        let crossPod = StatsEngine.headToHeadRecord(
            player1Id: players[0].id,
            player2Id: players[4].id,
            results: results
        )
        #expect(crossPod.totalGames == 0)

        // A vs B shared pod A, A finished ahead of B -> one win for A.
        let samePod = StatsEngine.headToHeadRecord(
            player1Id: players[0].id,
            player2Id: players[1].id,
            results: results
        )
        #expect(samePod.totalGames == 1)
        #expect(samePod.player1Wins == 1)
    }

    @Test("Single pod still shares one pod ID (legacy behavior preserved)")
    func singlePodSharesOnePodId() async throws {
        let context = try TestHelpers.bootstrappedContext()
        let players = TestFixtures.insertStandardPlayers(into: context)
        try context.save()

        LeagueEngine.createTournament(
            context: context,
            name: "Single Pod",
            totalWeeks: 1,
            randomPerWeek: 0,
            playerIds: players.map { $0.id }
        )
        LeagueEngine.confirmAttendance(
            context: context,
            presentIds: players.map { $0.id },
            achievementsOnThisWeek: false
        )

        // No pod groupings recorded (e.g. legacy/manual flow) -> single shared pod.
        for (index, player) in players.enumerated() {
            LeagueEngine.updatePlacement(context: context, playerId: player.id, placement: index + 1)
        }
        LeagueEngine.finalizeRound(context: context)

        let results = try TestHelpers.fetchAll(GameResult.self, from: context)
        #expect(Set(results.map { $0.podId }).count == 1)
    }

    // MARK: - Edit after advancing round

    @Test("Editing last round after advancing updates original results, not duplicates")
    func editAfterAdvanceUpdatesOriginalRound() async throws {
        let context = try TestHelpers.bootstrappedContext()
        let players = TestFixtures.insertStandardPlayers(into: context)
        try context.save()

        LeagueEngine.createTournament(
            context: context,
            name: "Edit After Advance",
            totalWeeks: 1,
            randomPerWeek: 0,
            playerIds: players.map { $0.id }
        )
        LeagueEngine.confirmAttendance(
            context: context,
            presentIds: players.map { $0.id },
            achievementsOnThisWeek: false
        )

        // Round 1: player 0 wins. Use nextRound so the tournament advances to round 2.
        for (index, player) in players.enumerated() {
            LeagueEngine.updatePlacement(context: context, playerId: player.id, placement: index + 1)
        }
        LeagueEngine.nextRound(context: context)

        var tournament = try TestHelpers.fetchActiveTournament(from: context)!
        #expect(tournament.currentRound == 2) // advanced past the round we will edit

        var results = try TestHelpers.fetchAll(GameResult.self, from: context)
        #expect(results.count == 4)
        #expect(results.allSatisfy { $0.round == 1 })

        // Edit the last (round 1) result: make player 3 the winner instead.
        let newPlacements: [String: Int] = [
            players[0].id: 4,
            players[1].id: 3,
            players[2].id: 2,
            players[3].id: 1
        ]
        LeagueEngine.applyEditedRound(
            context: context,
            newPlacements: newPlacements,
            newAchievementChecks: []
        )

        // No duplicate records: still exactly four, all still tagged round 1.
        results = try TestHelpers.fetchAll(GameResult.self, from: context)
        #expect(results.count == 4)
        #expect(results.allSatisfy { $0.round == 1 })

        // Edited placements applied to the original records.
        let p0 = results.first { $0.playerId == players[0].id }!
        let p3 = results.first { $0.playerId == players[3].id }!
        #expect(p0.placement == 4)
        #expect(p3.placement == 1)

        // Cumulative stats reflect the edit, not double-counting.
        #expect(players[0].placementPoints == 1) // 4th place
        #expect(players[0].wins == 0)
        #expect(players[3].placementPoints == 4) // 1st place
        #expect(players[3].wins == 1)
        #expect(players[0].gamesPlayed == 1)

        tournament = try TestHelpers.fetchActiveTournament(from: context)!
        #expect(tournament.podHistorySnapshots.count == 1)
    }

    @Test("Edit after advancing preserves the round's pod ID")
    func editAfterAdvancePreservesPodId() async throws {
        let context = try TestHelpers.bootstrappedContext()
        let players = TestFixtures.insertStandardPlayers(into: context)
        try context.save()

        LeagueEngine.createTournament(
            context: context,
            name: "Edit Pod ID",
            totalWeeks: 1,
            randomPerWeek: 0,
            playerIds: players.map { $0.id }
        )
        LeagueEngine.confirmAttendance(
            context: context,
            presentIds: players.map { $0.id },
            achievementsOnThisWeek: false
        )

        LeagueEngine.recordRoundPods(context: context, pods: [players.map { $0.id }])
        for (index, player) in players.enumerated() {
            LeagueEngine.updatePlacement(context: context, playerId: player.id, placement: index + 1)
        }
        LeagueEngine.nextRound(context: context)

        let originalPodId = try TestHelpers.fetchAll(GameResult.self, from: context).first!.podId

        let newPlacements: [String: Int] = [
            players[0].id: 2,
            players[1].id: 1,
            players[2].id: 3,
            players[3].id: 4
        ]
        LeagueEngine.applyEditedRound(
            context: context,
            newPlacements: newPlacements,
            newAchievementChecks: []
        )

        let results = try TestHelpers.fetchAll(GameResult.self, from: context)
        #expect(Set(results.map { $0.podId }) == [originalPodId])
    }
}
