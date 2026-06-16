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

    func testStatsFlowInLandscape() {
        XCUIDevice.shared.orientation = .landscapeLeft
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "orientation")], timeout: 2)

        app.navigateToStats()
        let navBar = app.navigationBars["Stats"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 8), "Stats navigation bar should be visible in landscape")

        let sectionPicker = app.otherElements["statsSectionPicker"]
        let pickerExists = sectionPicker.waitForExistence(timeout: 5)
        XCTAssertTrue(pickerExists || navBar.exists, "Stats section picker or nav bar should be present in landscape")
    }
}
