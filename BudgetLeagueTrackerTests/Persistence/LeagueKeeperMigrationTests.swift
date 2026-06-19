import Foundation
import SwiftData
import Testing
@testable import BudgetLeagueTracker

@Suite("LeagueKeeper migration")
@MainActor
struct LeagueKeeperMigrationTests {
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
