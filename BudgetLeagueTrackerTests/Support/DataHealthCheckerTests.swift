import Foundation
import SwiftData
import Testing
@testable import BudgetLeagueTracker

@Suite("DataHealthChecker")
@MainActor
struct DataHealthCheckerTests {
    @Test("Healthy tournament reports no issues")
    func healthyTournament() throws {
        let context = try TestHelpers.contextWithTournament()
        let issues = DataHealthChecker.scan(context: context)
        #expect(issues.isEmpty)
    }

    @Test("Corrupt weekly points JSON is surfaced with repair hint")
    func corruptWeeklyPoints() throws {
        let context = try TestHelpers.contextWithTournament()
        let tournament = try #require(LeagueEngine.fetchActiveTournament(context: context))
        tournament.weeklyPointsJSON = Data("{not valid json}".utf8)
        try context.save()

        let issues = DataHealthChecker.scan(context: context)
        #expect(issues.count == 1)
        #expect(issues[0].message.contains("weekly points"))
        #expect(issues[0].repairHint.contains("Export a backup"))
    }

    @Test("Corrupt table seatings JSON is surfaced")
    func corruptTableSeatings() throws {
        let context = try TestHelpers.contextWithTournament()
        let tournament = try #require(LeagueEngine.fetchActiveTournament(context: context))
        tournament.currentRoundPodsPlayerIdsData = Data("[broken".utf8)
        try context.save()

        let issues = DataHealthChecker.scan(context: context)
        #expect(issues.count == 1)
        #expect(issues[0].message.contains("table seatings"))
        #expect(issues[0].repairHint.contains("Seat players again"))
    }

    @Test("Empty JSON blobs are ignored")
    func emptyJSONIgnored() throws {
        let context = try TestHelpers.contextWithTournament()
        let tournament = try #require(LeagueEngine.fetchActiveTournament(context: context))
        tournament.weeklyPointsJSON = Data()
        tournament.podHistoryData = nil
        tournament.roundPlacementsData = Data()

        let issues = DataHealthChecker.scan(context: context)
        #expect(issues.isEmpty)
    }

    @Test("Corrupt game result achievement JSON is surfaced")
    func corruptGameResultAchievements() throws {
        let context = try TestHelpers.contextWithTournament()
        let tournament = try #require(LeagueEngine.fetchActiveTournament(context: context))
        let playerId = try #require(tournament.presentPlayerIds.first)
        let result = TestFixtures.gameResult(tournamentId: tournament.id, playerId: playerId, placement: 1)
        result.achievementIdsData = Data("{bad".utf8)
        context.insert(result)
        try context.save()

        let issues = DataHealthChecker.scan(context: context)
        #expect(issues.contains { $0.message.contains("achievement IDs") })
    }
}
