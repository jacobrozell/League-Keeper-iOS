import Foundation
import SwiftData
import Testing
@testable import BudgetLeagueTracker

@Suite("LeagueBackupService Tests", .serialized)
@MainActor
struct LeagueBackupServiceTests {

    @Test("Export and import round-trips league data")
    func roundTrip() throws {
        let source = try TestHelpers.bootstrappedContext()
        let player = TestFixtures.player(name: "Backup Pat")
        source.insert(player)

        let exportData = try LeagueBackupService.exportData(context: source)
        #expect(!exportData.isEmpty)

        let destination = try TestHelpers.cleanContext()
        try LeagueBackupService.importBackup(exportData, context: destination)

        let players = try TestHelpers.fetchAll(Player.self, from: destination)
        #expect(players.contains { $0.name == "Backup Pat" })

        let states = try TestHelpers.fetchAll(LeagueState.self, from: destination)
        #expect(states.count == 1)
    }

    @Test("Import rejects invalid JSON")
    func rejectsInvalidJSON() throws {
        let context = try TestHelpers.cleanContext()
        let invalid = Data("not json".utf8)

        #expect(throws: LeagueBackupError.self) {
            try LeagueBackupService.importBackup(invalid, context: context)
        }
    }

    @Test("Backup file includes tournaments and game results")
    func includesTournamentData() throws {
        let context = try TestHelpers.bootstrappedContext()
        let players = TestFixtures.players("A", "B", "C", "D")
        players.forEach { context.insert($0) }
        try context.save()

        LeagueEngine.createTournament(
            context: context,
            name: "Backup League",
            totalWeeks: 4,
            randomPerWeek: 1,
            playerIds: players.map(\.id)
        )

        let backup = try LeagueBackupService.makeBackupFile(context: context)
        #expect(backup.tournaments.count == 1)
        #expect(backup.tournaments.first?.name == "Backup League")
    }

    @Test("Import template is valid and imports cleanly")
    func importTemplate() throws {
        let data = try LeagueBackupService.templateData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let template = try decoder.decode(LeagueBackupFile.self, from: data)

        #expect(template.readme?.contains("HOW TO USE") == true)
        #expect(template.players.count == 8)
        #expect(template.achievements.count == 3)
        #expect(template.tournaments.count == 1)
        #expect(template.gameResults.isEmpty)

        let context = try TestHelpers.cleanContext()
        try LeagueBackupService.importBackup(data, context: context)

        let players = try TestHelpers.fetchAll(Player.self, from: context)
        #expect(players.count == 8)
        #expect(players.contains { $0.name == "Player 1" })

        let tournaments = try TestHelpers.fetchAll(Tournament.self, from: context)
        #expect(tournaments.first?.name == "My League (rename me)")
    }

    @Test("Preview import summarizes template contents")
    func previewImportTemplate() throws {
        let data = try LeagueBackupService.templateData()
        let preview = LeagueBackupService.previewImport(data)

        #expect(preview?.isTemplate == true)
        #expect(preview?.playerCount == 8)
        #expect(preview?.confirmationMessage.contains("starter template") == true)
        #expect(preview?.successMessage.contains("Tournaments") == true)
    }
}
