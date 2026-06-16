import XCTest

/// UI tests for Players screen
@MainActor
final class PlayersScreenTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }

    func testPlayersTabShowsScreen() {
        app.navigateToPlayers()
        let navBar = app.navigationBars["Players"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testEmptyStateOrList() {
        app.navigateToPlayers()
        let emptyMessage = app.staticTexts["No players yet"]
        let list = app.tables.firstMatch
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 5) || list.waitForExistence(timeout: 5))
    }
}
