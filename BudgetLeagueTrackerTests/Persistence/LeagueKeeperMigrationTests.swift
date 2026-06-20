import Foundation
import SwiftData
import Testing
@testable import BudgetLeagueTracker

@Suite("LeagueKeeper migration")
@MainActor
struct LeagueKeeperMigrationTests {
    @Test("Version 1.1 schema container boots in memory")
    func inMemoryContainerV2() throws {
        let container = try LeagueKeeperModelContainer.make(isStoredInMemoryOnly: true)
        let context = container.mainContext

        let tournament = Tournament(name: "Migration Test")
        context.insert(tournament)
        try context.save()

        #expect(tournament.leaguePreset == .simpleLeague)
        #expect(tournament.playersPerTable == 4)
        #expect(tournament.placementPointsScale == AppConstants.Scoring.defaultPlacementScale)
    }

    @Test("Versioned schema container boots in memory")
    func inMemoryContainer() throws {
        let container = try LeagueKeeperModelContainer.make(isStoredInMemoryOnly: true)
        let context = container.mainContext
        context.insert(LeagueState())
        try context.save()

        let states = try context.fetch(FetchDescriptor<LeagueState>())
        #expect(states.count == 1)
    }
}
