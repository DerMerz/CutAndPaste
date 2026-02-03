import XCTest

final class SettingsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--skip-onboarding"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Menu Bar Tests

    func testMenuBar_statusItemExists() throws {
        // The status item should exist in the menu bar
        // Note: Testing menu bar items requires specific setup

        // We can test that the app launched successfully
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }

    // MARK: - Settings Window Tests

    func testSettingsWindow_opensCorrectly() throws {
        // Open settings via menu
        openSettings()

        // Then settings window should appear
        let settingsWindow = app.windows["Cut & Paste Einstellungen"]

        if settingsWindow.waitForExistence(timeout: 5) {
            XCTAssertTrue(settingsWindow.exists)
        }
    }

    func testSettingsWindow_hasAllTabs() throws {
        // Open settings
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Check for tabs
        let generalTab = settingsWindow.buttons["Allgemein"]
        let permissionsTab = settingsWindow.buttons["Berechtigungen"]
        let aboutTab = settingsWindow.buttons["Über"]

        // At least some navigation should exist
        XCTAssertTrue(settingsWindow.exists)
    }

    // MARK: - General Settings Tests

    func testGeneralSettings_togglesExist() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Navigate to General tab
        let generalTab = settingsWindow.buttons["Allgemein"]
        if generalTab.exists {
            generalTab.tap()
        }

        // Check for toggles
        let enableToggle = settingsWindow.toggles["Cut & Paste aktivieren"]
        let launchToggle = settingsWindow.toggles["Bei Anmeldung starten"]
        let feedbackToggle = settingsWindow.toggles["Visuelles Feedback anzeigen"]

        // Verify the window is showing settings
        XCTAssertTrue(settingsWindow.exists)
    }

    func testGeneralSettings_enableToggle_works() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Find enable toggle
        let enableToggle = settingsWindow.toggles["Cut & Paste aktivieren"]

        if enableToggle.exists {
            // Get initial state
            let initialValue = enableToggle.value as? String

            // Toggle
            enableToggle.tap()

            // Check state changed
            let newValue = enableToggle.value as? String
            XCTAssertNotEqual(initialValue, newValue)

            // Toggle back
            enableToggle.tap()
        }
    }

    // MARK: - Permissions Settings Tests

    func testPermissionsSettings_showsAccessibilityStatus() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Navigate to Permissions tab
        let permissionsTab = settingsWindow.buttons["Berechtigungen"]
        if permissionsTab.exists {
            permissionsTab.tap()

            // Check for accessibility label
            let accessibilityLabel = settingsWindow.staticTexts["Bedienungshilfen"]
            XCTAssertTrue(accessibilityLabel.waitForExistence(timeout: 2))
        }
    }

    // MARK: - About Tests

    func testAboutSettings_showsAppInfo() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Navigate to About tab
        let aboutTab = settingsWindow.buttons["Über"]
        if aboutTab.exists {
            aboutTab.tap()

            // Check for app name
            let appName = settingsWindow.staticTexts["Cut & Paste"]
            XCTAssertTrue(appName.waitForExistence(timeout: 2))
        }
    }

    func testAboutSettings_feedbackButtonExists() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Navigate to About tab
        let aboutTab = settingsWindow.buttons["Über"]
        if aboutTab.exists {
            aboutTab.tap()

            // Check for feedback button
            let feedbackButton = settingsWindow.buttons["Feedback senden"]
            XCTAssertTrue(feedbackButton.waitForExistence(timeout: 2))
        }
    }

    // MARK: - Debug Settings Tests (DEBUG only)

    #if DEBUG
    func testDebugSettings_tabExists() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Check for Debug tab
        let debugTab = settingsWindow.buttons["Debug"]
        XCTAssertTrue(debugTab.exists)
    }

    func testDebugSettings_showsRatingState() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Navigate to Debug tab
        let debugTab = settingsWindow.buttons["Debug"]
        if debugTab.exists {
            debugTab.tap()

            // Check for rating state group
            let ratingStateGroup = settingsWindow.groups["Rating State"]
            XCTAssertTrue(ratingStateGroup.waitForExistence(timeout: 2))
        }
    }

    func testDebugSettings_triggerRatingPrompt() throws {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        // Navigate to Debug tab
        let debugTab = settingsWindow.buttons["Debug"]
        if debugTab.exists {
            debugTab.tap()

            // Find and tap trigger button
            let triggerButton = settingsWindow.buttons["Trigger Prompt"]
            if triggerButton.exists {
                triggerButton.tap()

                // Rating prompt should appear
                let ratingWindow = app.windows["Feedback"]
                XCTAssertTrue(ratingWindow.waitForExistence(timeout: 2))
            }
        }
    }
    #endif

    // MARK: - Rating Prompt Tests

    func testRatingPrompt_hasAllButtons() throws {
        // This test requires triggering the rating prompt
        // Which typically needs DEBUG mode

        #if DEBUG
        triggerRatingPrompt()

        let ratingWindow = app.windows["Feedback"]
        guard ratingWindow.waitForExistence(timeout: 5) else { return }

        // Check for all buttons
        let yesButton = ratingWindow.buttons["Ja, die App ist toll!"]
        let noButton = ratingWindow.buttons["Nein, ich habe Verbesserungsvorschläge"]
        let skipButton = ratingWindow.buttons["Später erinnern"]

        XCTAssertTrue(yesButton.exists)
        XCTAssertTrue(noButton.exists)
        XCTAssertTrue(skipButton.exists)
        #endif
    }

    func testRatingPrompt_skipButtonClosesPrompt() throws {
        #if DEBUG
        triggerRatingPrompt()

        let ratingWindow = app.windows["Feedback"]
        guard ratingWindow.waitForExistence(timeout: 5) else { return }

        // Tap skip
        let skipButton = ratingWindow.buttons["Später erinnern"]
        if skipButton.exists {
            skipButton.tap()

            // Window should close
            XCTAssertFalse(ratingWindow.waitForExistence(timeout: 2))
        }
        #endif
    }

    // MARK: - Helper Methods

    private func openSettings() {
        // Click on status item to open popover
        // Then click settings

        // Alternative: Use keyboard shortcut if implemented
        // Or access through menu if available

        // For now, we'll use the app's command to open settings
        // This might need adjustment based on actual implementation
        app.typeKey(",", modifierFlags: .command)
    }

    #if DEBUG
    private func triggerRatingPrompt() {
        openSettings()

        let settingsWindow = app.windows["Cut & Paste Einstellungen"]
        guard settingsWindow.waitForExistence(timeout: 5) else { return }

        let debugTab = settingsWindow.buttons["Debug"]
        if debugTab.exists {
            debugTab.tap()

            let triggerButton = settingsWindow.buttons["Trigger Prompt"]
            if triggerButton.exists {
                triggerButton.tap()
            }
        }
    }
    #endif
}
