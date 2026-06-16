import XCTest

/// UI tests for Dashboard / Tournaments screen (main landing)
@MainActor
final class DashboardScreenTests: XCTestCase {

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

    func testDashboardTabShowsScreen() {
        app.navigateToTournaments()
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testEmptyStateOrTournamentList() {
        app.navigateToTournaments()
        let createButton = app.buttons["Create Tournament"]
        let emptyMessage = app.staticTexts["No tournaments yet"]
        let addButton = app.buttons["Add"]
        let hasContent = createButton.waitForExistence(timeout: 5)
            || emptyMessage.waitForExistence(timeout: 5)
            || addButton.waitForExistence(timeout: 3)
        XCTAssertTrue(hasContent)
    }
}
