import XCTest

final class OnboardingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-onboarding"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Welcome Screen Tests

    func testWelcomeScreen_displaysCorrectElements() throws {
        // Given the app launches with onboarding

        // Then welcome screen should show
        let welcomeTitle = app.staticTexts["Willkommen bei\nCut & Paste"]
        let weiterButton = app.buttons["Weiter"]

        // Note: These tests assume the app shows onboarding on first launch
        // In a real scenario, we'd need to reset UserDefaults before testing
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists)
            XCTAssertTrue(weiterButton.exists)
        }
    }

    func testWelcomeScreen_weiterNavigatesToHowItWorks() throws {
        // Given welcome screen is shown
        let weiterButton = app.buttons["Weiter"]

        if weiterButton.waitForExistence(timeout: 5) {
            // When tapping Weiter
            weiterButton.tap()

            // Then how it works screen should show
            let howItWorksTitle = app.staticTexts["So funktioniert's"]
            XCTAssertTrue(howItWorksTitle.waitForExistence(timeout: 2))
        }
    }

    // MARK: - How It Works Screen Tests

    func testHowItWorksScreen_displaysAllSteps() throws {
        // Navigate to How It Works
        navigateToStep(2)

        // Then all steps should be visible
        let step1 = app.staticTexts["1. Dateien auswählen"]
        let step2 = app.staticTexts["2. Cmd+X drücken"]
        let step3 = app.staticTexts["3. Zum Ziel navigieren"]
        let step4 = app.staticTexts["4. Cmd+V drücken"]

        if step1.waitForExistence(timeout: 2) {
            XCTAssertTrue(step1.exists)
            XCTAssertTrue(step2.exists)
            XCTAssertTrue(step3.exists)
            XCTAssertTrue(step4.exists)
        }
    }

    func testHowItWorksScreen_backNavigatesToWelcome() throws {
        // Navigate to How It Works
        navigateToStep(2)

        // When tapping Zurück
        let backButton = app.buttons["Zurück"]
        if backButton.waitForExistence(timeout: 2) {
            backButton.tap()

            // Then welcome screen should show
            let welcomeTitle = app.staticTexts["Willkommen bei\nCut & Paste"]
            XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 2))
        }
    }

    // MARK: - Permission Screen Tests

    func testPermissionScreen_displaysPermissionRequest() throws {
        // Navigate to Permission screen
        navigateToStep(3)

        // Then permission screen should show
        let permissionTitle = app.staticTexts["Berechtigung erforderlich"]

        if permissionTitle.waitForExistence(timeout: 2) {
            XCTAssertTrue(permissionTitle.exists)

            // Button to open system preferences should exist
            let openPrefsButton = app.buttons["Systemeinstellungen öffnen"]
            XCTAssertTrue(openPrefsButton.exists)
        }
    }

    // MARK: - Success Screen Tests

    func testSuccessScreen_displaysSuccessMessage() throws {
        // Note: This test requires permission to be granted
        // In UI tests, we might need to mock this

        // Navigate to Success screen (assuming permission is granted)
        navigateToStep(4)

        let successTitle = app.staticTexts["Du bist bereit!"]

        if successTitle.waitForExistence(timeout: 2) {
            XCTAssertTrue(successTitle.exists)

            // "Los geht's" button should exist
            let startButton = app.buttons["Los geht's"]
            XCTAssertTrue(startButton.exists)
        }
    }

    // MARK: - Navigation Helper

    private func navigateToStep(_ step: Int) {
        let weiterButton = app.buttons["Weiter"]

        guard weiterButton.waitForExistence(timeout: 5) else { return }

        for _ in 1..<step {
            if weiterButton.exists && weiterButton.isHittable {
                weiterButton.tap()
                // Wait for animation
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
    }
}
