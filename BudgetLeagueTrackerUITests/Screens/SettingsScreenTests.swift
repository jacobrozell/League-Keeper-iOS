import XCTest

/// UI tests for Settings screen
@MainActor
final class SettingsScreenTests: XCTestCase {

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

    func testSettingsTabShowsScreen() {
        app.navigateToSettings()
        let navBar = app.navigationBars["Settings"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testAboutSectionExists() {
        app.navigateToSettings()
        let about = app.staticTexts["About"]
        XCTAssertTrue(about.waitForExistence(timeout: 5))
    }

    func testThemePickerExists() {
        app.navigateToSettings()
        let appearance = app.staticTexts["Appearance"]
        XCTAssertTrue(appearance.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Theme"].waitForExistence(timeout: 5) || app.staticTexts["Theme"].exists)
    }

    func testSettingsInLandscape() {
        XCUIDevice.shared.orientation = .landscapeLeft
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "orientation")], timeout: 2)

        app.navigateToSettings()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Appearance"].waitForExistence(timeout: 5))
    }
}
