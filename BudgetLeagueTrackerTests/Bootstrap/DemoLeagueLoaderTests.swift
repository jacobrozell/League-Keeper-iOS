import Foundation
import SwiftData
import Testing
@testable import BudgetLeagueTracker

@Suite("DemoLeagueLoader")
@MainActor
struct DemoLeagueLoaderTests {
    @Test("loads players, achievements, and a tournament")
    func loadsSampleLeague() throws {
        let context = try TestHelpers.bootstrappedContext()

        let result = try DemoLeagueLoader.load(into: context)

        #expect(result.playerCount == DemoLeagueLoader.playerNames.count)
        #expect(result.tournamentName == DemoLeagueLoader.tournamentName)

        let players = try context.fetch(FetchDescriptor<Player>())
        #expect(players.count == DemoLeagueLoader.playerNames.count)

        let tournaments = try context.fetch(FetchDescriptor<Tournament>())
        #expect(tournaments.count == 1)
        #expect(tournaments.first?.name == DemoLeagueLoader.tournamentName)
        #expect(result.tournamentId == tournaments.first?.id)

        let achievements = LeagueEngine.fetchAllAchievements(context: context)
        #expect(achievements.contains { $0.name == "Combat Damage Master" })
    }

    @Test("refuses to load when tournaments already exist")
    func refusesWhenDataExists() throws {
        let context = try TestHelpers.bootstrappedContext()

        _ = try DemoLeagueLoader.load(into: context)

        #expect(throws: DemoLeagueLoader.LoadError.self) {
            try DemoLeagueLoader.load(into: context)
        }
    }
}
