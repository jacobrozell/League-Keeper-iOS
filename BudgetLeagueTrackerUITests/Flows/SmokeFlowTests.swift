import XCTest

/// PR smoke: launch, create a tournament, confirm attendance, and score one round.
@MainActor
final class SmokeFlowTests: XCTestCase {

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

    func testCreateTournamentAndScoreOneRound() {
        app.navigateToTournaments()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 8), "App should launch to Tournaments")

        let createButton = app.buttons["Create Tournament"]
        if createButton.waitForExistence(timeout: 3) {
            createButton.tap()
        } else {
            let addButton = app.buttons["Add"]
            XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Create tournament entry point should exist")
            addButton.tap()
        }

        let nameField = app.textFields["e.g., Spring 2026 League"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 8), "New Tournament form should appear")
        nameField.tap()
        nameField.typeText("Smoke League")

        let suffix = String(UUID().uuidString.prefix(4))
        let addPlayerField = app.textFields["Add player"]
        XCTAssertTrue(addPlayerField.waitForExistence(timeout: 3), "Add player field should exist")
        for name in ["Ana", "Ben", "Cal", "Dee"] {
            addPlayerField.tap()
            addPlayerField.typeText("\(name) \(suffix)")
            app.buttons["Add player"].tap()
        }
        if app.keyboards.count > 0 {
            app.swipeDown()
        }

        let submit = app.buttons["Submit Create Tournament"]
        XCTAssertTrue(submit.waitForExistence(timeout: 3) && submit.isEnabled, "Create should be enabled")
        submit.tap()

        app.confirmAttendance()
        app.ensureRoundScored()

        app.buttons.matching(identifier: "Next Round").firstMatch.tap()
        let finishRound = app.alerts.buttons["Finish Round"]
        XCTAssertTrue(finishRound.waitForExistence(timeout: 3), "Finish round confirmation should appear")
        finishRound.tap()

        XCTAssertTrue(app.buttons["Seat Players"].waitForExistence(timeout: 8), "Round 2 should be ready to seat")
    }
}
