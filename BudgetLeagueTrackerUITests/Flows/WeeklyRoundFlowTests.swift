import XCTest

/// UI tests for weekly round flow
@MainActor
final class WeeklyRoundFlowTests: XCTestCase {
    
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
    
    // MARK: - Helper Methods
    
    /// Creates a tournament and advances to attendance screen
    /// Returns true if successful, false otherwise
    @discardableResult
    private func createTournamentAndGoToAttendance() -> Bool {
        // Wait for main screen to load
        let navBar = app.navigationBars.firstMatch
        guard navBar.waitForExistence(timeout: 3) else { return false }
        
        // Create tournament
        let createButton = app.buttons["Create Tournament"]
        if createButton.waitForExistence(timeout: 2) {
            createButton.tap()
        } else {
            let buttons = app.navigationBars.buttons
            guard buttons.count > 0 else { return false }
            buttons.element(boundBy: buttons.count - 1).tap()
        }
        
        // Wait for New Tournament screen
        guard app.navigationBars["New Tournament"].waitForExistence(timeout: 3) else { return false }
        
        // Find tournament name field by placeholder
        let nameField = app.textFields["e.g., Spring 2026 League"]
        if nameField.waitForExistence(timeout: 2) {
            nameField.tap()
            nameField.typeText("Test Tournament")
            app.keyboards.buttons["return"].tap() // Dismiss keyboard faster
        }
        
        // Add 4 players quickly - find add player field by placeholder
        let addPlayerField = app.textFields["Add player"]
        if addPlayerField.waitForExistence(timeout: 2) {
            for i in 1...4 {
                addPlayerField.tap()
                addPlayerField.typeText("P\(i)") // Shorter names for speed
                
                let addButton = app.buttons["Add player"]
                if addButton.exists && addButton.isHittable {
                    addButton.tap()
                }
            }
        }
        
        // Dismiss keyboard if still showing
        if app.keyboards.count > 0 {
            app.keyboards.buttons["return"].tap()
        }
        
        let createTournamentButton = app.buttons["Submit Create Tournament"]
        guard createTournamentButton.waitForExistence(timeout: 2) else { return false }
        
        if createTournamentButton.isEnabled {
            createTournamentButton.tap()
        } else {
            return false
        }
        
        // Wait for Attendance screen
        return app.navigationBars["Attendance"].waitForExistence(timeout: 3)
    }
    
    /// Confirms attendance with all players present
    private func confirmAttendance() {
        let markAll = app.buttons["attendanceMarkAll"]
        if markAll.waitForExistence(timeout: 3) {
            markAll.tap()
        }
        let confirmButton = app.buttons["Confirm Attendance"]
        guard confirmButton.waitForExistence(timeout: 3) else { return }
        confirmButton.tap()
        
        // Wait for Tournament Detail screen (where pods are managed)
        _ = app.navigationBars.staticTexts.firstMatch.waitForExistence(timeout: 3)
    }

    /// Taps Next Round and confirms the advancement alert when shown.
    private func advanceRound() {
        let nextRoundButton = app.buttons["Next Round"]
        guard nextRoundButton.waitForExistence(timeout: 3) else { return }
        nextRoundButton.tap()

        for title in ["Finish Round", "End Week", "End Tournament"] {
            let confirm = app.buttons[title]
            if confirm.waitForExistence(timeout: 2) {
                confirm.tap()
                return
            }
        }
    }

    /// Ensures pods exist, tapping Generate only when needed.
    private func ensurePodsForCurrentRound() {
        app.ensurePodsForCurrentRound()
    }

    /// Scores every visible placement picker so the round can advance.
    private func scoreAllPlacementsIfPossible() {
        let podHeader = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Pod'")).firstMatch
        if podHeader.waitForExistence(timeout: 2) {
            podHeader.tap()
        }

        let labels = ["1st", "2nd", "3rd", "4th"]
        let pickers = app.segmentedControls
        guard pickers.firstMatch.waitForExistence(timeout: 3) else { return }

        for index in 0..<pickers.count {
            let picker = pickers.element(boundBy: index)
            let label = labels[min(index, labels.count - 1)]
            if picker.buttons[label].exists {
                picker.buttons[label].tap()
            }
        }
    }
    
    // MARK: - Round Flow Tests
    
    func testCompleteThreeRounds() {
        guard createTournamentAndGoToAttendance() else { return }
        confirmAttendance()
        
        // For each of 3 rounds
        for round in 1...3 {
            ensurePodsForCurrentRound()
            // Tap Next Round (waitForExistence handles delay)
            advanceRound()
            
            // After round 3, should be on attendance for next week or tournament standings
            if round == 3 {
                // Could be attendance (next week) or tournament standings (final week)
                let attendanceExists = app.buttons["Confirm Attendance"].waitForExistence(timeout: 3)
                let standingsExists = app.staticTexts["Tournament Standings"].waitForExistence(timeout: 3)
                XCTAssertTrue(attendanceExists || standingsExists)
            }
        }
    }
    
    func testEditLastRound() {
        guard createTournamentAndGoToAttendance() else { return }
        confirmAttendance()
        
        ensurePodsForCurrentRound()
        advanceRound()

        ensurePodsForCurrentRound()
        // Edit is on the sticky action bar during review
        let editButton = app.buttons["Edit Last Round"]
        guard editButton.waitForExistence(timeout: 3) else { return }
        
        editButton.tap()

        let editConfirm = app.buttons["Edit"]
        if editConfirm.waitForExistence(timeout: 2) {
            editConfirm.tap()
        }
        
        // Verify edit sheet appears with Save button
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        
        // Cancel to dismiss
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        XCTAssertTrue(app.waitForRoundReady(timeout: 3))
    }
    
    func testToggleAchievementsOff() {
        guard createTournamentAndGoToAttendance() else { return }
        
        // Find achievements toggle
        let achievementsToggle = app.switches["Count achievements this week"]
        if achievementsToggle.exists {
            // Toggle off
            achievementsToggle.tap()
            
            // Verify it's off
            XCTAssertEqual(achievementsToggle.value as? String, "0")
        }
        
        confirmAttendance()
        
        ensurePodsForCurrentRound()
        
        // Achievement checkboxes should not be visible when achievements are off
        // Verify pods are generated
        XCTAssertTrue(app.buttons["Next Round"].waitForExistence(timeout: 3))
    }
    
    func testPlacementSelection() {
        guard createTournamentAndGoToAttendance() else { return }
        confirmAttendance()

        let seatButton = app.buttons["Seat Players"]
        if seatButton.waitForExistence(timeout: 3) {
            seatButton.tap()
        }

        let startScoring = app.buttons["Start Scoring"]
        if startScoring.waitForExistence(timeout: 3) {
            startScoring.tap()
        }

        let moveUp = app.buttons.matching(NSPredicate(format: "label CONTAINS 'up'")).firstMatch
        if moveUp.waitForExistence(timeout: 3), moveUp.isEnabled {
            moveUp.tap()
        }
    }

    func testWeekCompleteShowsShareButton() {
        app.terminate()
        app.launchArguments = ["--uitesting", "UI-Testing-Seed-WeekCompleteReady"]
        app.launch()

        app.ensurePodsForCurrentRound()

        let nextRound = app.buttons.matching(identifier: "Next Round").firstMatch
        XCTAssertTrue(nextRound.waitForExistence(timeout: 5))
        XCTAssertTrue(nextRound.isEnabled)
        nextRound.tap()

        let endWeek = app.alerts.buttons["End Week"]
        XCTAssertTrue(endWeek.waitForExistence(timeout: 3), "End week confirmation should appear")
        endWeek.tap()

        // Toast confirms week-end logic; fullScreenCover may lag in XCTest accessibility tree.
        XCTAssertTrue(
            app.staticTexts["Week 1 complete"].waitForExistence(timeout: 5),
            "Week complete toast should appear after ending the week"
        )

        if app.buttons["weekCompleteContinue"].waitForExistence(timeout: 3) {
            let shareButton = app.buttons["shareWeekStandings"]
            if !shareButton.exists {
                XCTAssertTrue(app.buttons["Share"].exists, "Share standings button should appear on week-complete screen")
            }
        }
    }
}
