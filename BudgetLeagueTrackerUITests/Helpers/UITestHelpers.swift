import XCTest

/// Helper methods for UI tests
extension XCUIApplication {
    
    // MARK: - Navigation Helpers
    
    /// Navigate to a specific tab
    func navigateToTab(_ tabName: String) {
        let tabBar = tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            tabBar.buttons[tabName].tap()
        }
    }
    
    /// Navigate to Tournaments tab
    func navigateToTournaments() {
        let tabBar = tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            let tournamentsTab = tabBar.buttons["Tournaments"]
            if tournamentsTab.exists {
                tournamentsTab.tap()
            }
        }
    }
    
    /// Navigate to Players tab
    func navigateToPlayers() {
        navigateToTab("Players")
    }
    
    /// Navigate to Stats tab
    func navigateToStats() {
        navigateToTab("Stats")
    }
    
    /// Navigate to Achievements tab
    func navigateToAchievements() {
        navigateToTab("Achievements")
    }
    
    /// Navigate to Settings tab
    func navigateToSettings() {
        navigateToTab("Settings")
    }

    /// Opens a seeded ongoing tournament from the tournaments list (requires `UI-Testing-Seed-*` launch arg).
    /// No-op when launch args already auto-navigate to tournament detail.
    func openSeededOngoingTournament(named name: String = "UI Test League") {
        let detailPicker = descendants(matching: .any)["tournamentDetailSectionPicker"]
        if detailPicker.waitForExistence(timeout: 2) {
            return
        }

        navigateToTournaments()

        let identifier = "tournament-\(name)"
        let byIdentifier = descendants(matching: .any)[identifier]
        if byIdentifier.waitForExistence(timeout: 4), byIdentifier.isHittable {
            byIdentifier.tap()
            return
        }

        let cell = tables.cells.containing(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
        if cell.waitForExistence(timeout: 4) {
            cell.tap()
        }
    }
    
    // MARK: - Tournament Creation Helpers
    
    /// Creates a tournament with the given name and player names
    func createTournament(name: String, playerNames: [String] = []) {
        // Tap create button - try empty state button first, then toolbar button
        let createButton = buttons["Create Tournament"]
        if createButton.waitForExistence(timeout: 5) {
            createButton.tap()
        } else {
            let addButton = buttons["Add"]
            if addButton.waitForExistence(timeout: 3) {
                addButton.tap()
            }
        }
        
        // Enter tournament name
        let nameField = textFields["Tournament Name"]
        if nameField.waitForExistence(timeout: 5) {
            nameField.tap()
            nameField.typeText(name)
        }
        
        // Add players
        let addPlayerField = textFields["Player Name"]
        for playerName in playerNames {
            if addPlayerField.waitForExistence(timeout: 3) {
                addPlayerField.tap()
                addPlayerField.typeText(playerName)
                buttons["Add"].tap()
            }
        }
        
        // Create tournament
        buttons["Submit Create Tournament"].tap()
    }
    
    /// Confirms attendance with all players present
    func confirmAttendance() {
        let markAll = buttons["attendanceMarkAll"]
        if markAll.waitForExistence(timeout: 3) {
            markAll.tap()
        }
        let confirmButton = buttons["Confirm Attendance"]
        if confirmButton.waitForExistence(timeout: 5) {
            confirmButton.tap()
        }
    }
    
    /// Waits until the round tab is ready for interaction.
    @discardableResult
    func waitForRoundReady(timeout: TimeInterval = 8) -> Bool {
        let readyButtons = [
            "Seat Players",
            "Start Scoring",
            "Done with Table",
            "Next Table",
            "Next Round",
            "Reshuffle Tables"
        ]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            for title in readyButtons {
                if buttons[title].exists { return true }
            }
            if buttons.matching(identifier: "Next Round").firstMatch.exists { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return false
    }

    /// Seats players, scores every table, and waits until the round can be finished.
    func ensureRoundScored(timeout: TimeInterval = 12) {
        XCTAssertTrue(waitForRoundReady(timeout: timeout), "Round tab should be ready")

        let seatButton = buttons["Seat Players"]
        if seatButton.waitForExistence(timeout: 2) {
            seatButton.tap()
        }

        let startScoring = buttons["Start Scoring"]
        if startScoring.waitForExistence(timeout: 3) {
            startScoring.tap()
        }

        confirmAllTables(timeout: timeout)

        XCTAssertTrue(
            buttons.matching(identifier: "Next Round").firstMatch.waitForExistence(timeout: timeout),
            "Finish round button should appear after all tables are scored"
        )
    }

    /// Legacy name used by existing UI tests.
    func ensurePodsForCurrentRound(timeout: TimeInterval = 12) {
        ensureRoundScored(timeout: timeout)
    }

    private func confirmAllTables(timeout: TimeInterval) {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if buttons.matching(identifier: "Next Round").firstMatch.exists {
                return
            }

            let doneButton = buttons["Done with Table"]
            if doneButton.waitForExistence(timeout: 1) {
                doneButton.tap()
                continue
            }

            let nextTable = buttons["Next Table"]
            if nextTable.waitForExistence(timeout: 1) {
                nextTable.tap()
                continue
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
    }

    /// Scores the current round and advances to the next round or week.
    func generateAndAdvanceRound() {
        ensureRoundScored()
        let nextRoundButton = buttons.matching(identifier: "Next Round").firstMatch
        if nextRoundButton.waitForExistence(timeout: 3) {
            nextRoundButton.tap()
            let confirm = alerts.buttons["Finish Round"]
            if confirm.waitForExistence(timeout: 2) {
                confirm.tap()
            } else if alerts.buttons["End Week"].waitForExistence(timeout: 1) {
                alerts.buttons["End Week"].tap()
            } else if alerts.buttons["End Tournament"].waitForExistence(timeout: 1) {
                alerts.buttons["End Tournament"].tap()
            }
        }
    }

    /// Opens the More menu on the tournament round sticky action bar.
    func openPodsMoreMenu() {
        let moreMenu = buttons["roundMoreMenu"]
        XCTAssertTrue(moreMenu.waitForExistence(timeout: 5), "Round more menu should exist")
        moreMenu.tap()
    }

    /// Selects a section on the tournament detail segmented control or menu picker.
    func selectTournamentDetailSection(_ title: String) {
        let picker = descendants(matching: .any)["tournamentDetailSectionPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Tournament detail section picker should exist")

        if picker.buttons[title].waitForExistence(timeout: 1) {
            picker.buttons[title].tap()
            return
        }

        picker.tap()

        let menuOption = buttons[title]
        if menuOption.waitForExistence(timeout: 3) {
            menuOption.tap()
            return
        }

        let menuItem = menus.buttons[title]
        XCTAssertTrue(menuItem.waitForExistence(timeout: 3), "Section menu option \(title) should exist")
        menuItem.tap()
    }
    
    // MARK: - Verification Helpers
    
    /// Verifies the current screen by checking the navigation bar title
    func verifyScreen(titled title: String) -> Bool {
        return navigationBars[title].waitForExistence(timeout: 5)
    }
    
    /// Verifies that a specific element exists
    func verifyElementExists(_ identifier: String) -> Bool {
        let element = descendants(matching: .any)[identifier]
        return element.waitForExistence(timeout: 5)
    }
    
    // MARK: - Form Helpers
    
    /// Enters text into a text field with the given identifier
    func enterText(_ text: String, inFieldWithIdentifier identifier: String) {
        let field = textFields[identifier]
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.typeText(text)
        }
    }
    
    /// Taps a button with the given title
    func tapButton(titled title: String) {
        let button = buttons[title]
        if button.waitForExistence(timeout: 5) {
            button.tap()
        }
    }
    
    /// Toggles a switch with the given identifier
    func toggleSwitch(identifier: String) {
        let toggle = switches[identifier]
        if toggle.waitForExistence(timeout: 5) {
            toggle.tap()
        }
    }
    
    // MARK: - Wait Helpers
    
    /// Waits for an element to appear and then disappear (for loading states)
    func waitForLoadingToComplete(timeout: TimeInterval = 10) {
        let loadingIndicator = activityIndicators.firstMatch
        if loadingIndicator.exists {
            _ = loadingIndicator.waitForExistence(timeout: timeout)
        }
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    
    /// Clears existing text and enters new text
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to get text value")
            return
        }
        
        tap()
        
        // Select all and delete
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
        
        // Enter new text
        typeText(text)
    }
    
    /// Waits for element to be hittable (visible and enabled)
    func waitForHittable(timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
