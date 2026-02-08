import XCTest

/// UI tests for Stats screen
@MainActor
final class StatsScreenTests: XCTestCase {

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

    func testStatsTabShowsScreen() {
        app.navigateToStats()
        let navBar = app.navigationBars["Stats"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }
}
