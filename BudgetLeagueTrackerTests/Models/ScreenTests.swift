import Testing
import Foundation
@testable import BudgetLeagueTracker

@Suite("Screen Enum Tests")
struct ScreenTests {

    @Test("Current screen raw values")
    func currentRawValues() {
        #expect(Screen.tournaments.rawValue == "tournaments")
        #expect(Screen.newTournament.rawValue == "newTournament")
        #expect(Screen.attendance.rawValue == "attendance")
        #expect(Screen.tournamentStandings.rawValue == "tournamentStandings")
        #expect(Screen.tournamentDetail.rawValue == "tournamentDetail")
    }

    @Test("Legacy values migrate to current screens", arguments: [
        ("dashboard", Screen.tournaments),
        ("pods", Screen.tournaments),
        ("confirmNewTournament", Screen.newTournament),
        ("addPlayers", Screen.newTournament),
        ("tournaments", Screen.tournaments),
        ("unknown", Screen.tournaments),
    ])
    func legacyMigration(rawValue: String, expected: Screen) {
        #expect(Screen.migrated(from: rawValue) == expected)
    }

    @Test("LeagueState screen getter migrates legacy persisted values")
    func leagueStateMigration() {
        let state = LeagueState(currentScreen: "pods")
        #expect(state.screen == .tournaments)
        #expect(state.currentScreen == "pods")
    }

    @Test("All cases encode and decode", arguments: Screen.allCases)
    func allCasesEncodeDecode(screen: Screen) throws {
        let encoded = try JSONEncoder().encode(screen)
        let decoded = try JSONDecoder().decode(Screen.self, from: encoded)
        #expect(decoded == screen)
    }

    @Test("Contains five navigation screens")
    func caseCount() {
        #expect(Screen.allCases.count == 5)
    }
}
