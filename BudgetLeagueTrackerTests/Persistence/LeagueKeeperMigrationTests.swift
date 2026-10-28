import Foundation
import SwiftData
import Testing
@testable import BudgetLeagueTracker

@Suite("LeagueKeeper migration", .serialized)
@MainActor
struct LeagueKeeperMigrationTests {
    @Test("Schema container boots in memory with tournament defaults")
    func inMemoryContainerWithTournamentDefaults() throws {
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

    @Test("Migration plan versions are unique and end at the current schema")
    func migrationPlanVersionsAreUnique() {
        let versions = LeagueKeeperMigrationPlan.schemas.map { $0.versionIdentifier }
        #expect(Set(versions.map(\.description)).count == versions.count)
        #expect(versions.last == LeagueKeeperSchemaV1.versionIdentifier)
        #expect(LeagueKeeperMigrationPlan.stages.count == LeagueKeeperMigrationPlan.schemas.count - 1)
    }

    @Test("On-disk league data survives reopening through the migration plan")
    func onDiskStoreSurvivesReopen() throws {
        let url = try Self.temporaryStoreURL()
        defer { Self.removeStore(at: url) }

        let ids = try Self.seedLeague(in: LeagueKeeperModelContainer.make(url: url))
        try Self.expectLeague(ids, in: LeagueKeeperModelContainer.make(url: url))
    }

    @Test("Store created before schema versioning opens with the versioned container")
    func unversionedStoreOpensWithMigrationPlan() throws {
        let url = try Self.temporaryStoreURL()
        defer { Self.removeStore(at: url) }

        let ids = try Self.seedLeague(in: ModelContainer(
            for: Schema(LeagueKeeperSchemaV1.models),
            configurations: [ModelConfiguration(url: url)]
        ))
        try Self.expectLeague(ids, in: LeagueKeeperModelContainer.make(url: url))
    }

    // MARK: - Helpers

    private struct SeededIDs {
        let tournamentId: String
        let playerIds: [String]
    }

    private static func seedLeague(in container: ModelContainer) throws -> SeededIDs {
        let context = ModelContext(container)
        let players = ["Ada", "Ben", "Cy", "Dee"].map { Player(name: $0) }
        players.forEach { context.insert($0) }

        let tournament = Tournament(name: "Persisted League", totalWeeks: 6, randomAchievementsPerWeek: 1)
        tournament.currentWeek = 2
        tournament.presentPlayerIds = players.map(\.id)
        tournament.podHistorySnapshots = [
            PodSnapshot(
                week: 1,
                round: 3,
                playerIds: players.map(\.id),
                placements: [players[0].id: 1],
                achievementChecks: [],
                playerDeltas: [:],
                weeklyDeltas: [:],
                achievementsOn: true,
                activeAchievementIds: []
            ),
        ]
        context.insert(tournament)
        context.insert(GameResult(
            tournamentId: tournament.id,
            week: 1,
            round: 3,
            playerId: players[0].id,
            placement: 1,
            placementPoints: 4,
            achievementPoints: 0,
            achievementIds: [],
            podId: "pod-1"
        ))

        let state = LeagueState()
        state.activeTournamentId = tournament.id
        context.insert(state)
        try context.save()

        return SeededIDs(tournamentId: tournament.id, playerIds: players.map(\.id))
    }

    private static func expectLeague(_ ids: SeededIDs, in container: ModelContainer) throws {
        let context = ModelContext(container)

        let players = try context.fetch(FetchDescriptor<Player>())
        #expect(Set(players.map(\.id)) == Set(ids.playerIds))

        let tournament = try #require(try context.fetch(FetchDescriptor<Tournament>()).first)
        #expect(tournament.id == ids.tournamentId)
        #expect(tournament.currentWeek == 2)
        #expect(tournament.presentPlayerIds == ids.playerIds)
        #expect(tournament.podHistorySnapshots.first?.achievementsOn == true)

        #expect(try context.fetch(FetchDescriptor<GameResult>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<LeagueState>()).first?.activeTournamentId == ids.tournamentId)
    }

    private static func temporaryStoreURL() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("LeagueKeeperMigrationTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("League.store")
    }

    private static func removeStore(at url: URL) {
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }
}
