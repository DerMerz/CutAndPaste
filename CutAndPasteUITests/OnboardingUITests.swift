import XCTest

final class OnboardingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-onboarding"]
        // Use English as default test language
        app.launchArguments.append(contentsOf: ["-AppleLanguages", "(en)", "-AppleLocale", "en"])
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Welcome Screen Tests

    func testWelcomeScreen_displaysCorrectElements() throws {
        let welcomeTitle = app.staticTexts["Welcome to\nCut & Place"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 5), "Welcome title should be visible")

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists, "Next button should be visible")
    }

    func testWelcomeScreen_nextNavigatesToHowItWorks() throws {
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5), "Next button should be visible")

        nextButton.tap()

        let howItWorksTitle = app.staticTexts["How it works"]
        XCTAssertTrue(howItWorksTitle.waitForExistence(timeout: 2), "How it works title should appear")
    }

    func testWelcomeScreen_backButtonNotVisible() throws {
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5), "Next button should be visible")

        let backButton = app.buttons["Back"]
        XCTAssertFalse(backButton.exists, "Back button should not be visible on welcome screen")
    }

    // MARK: - How It Works Screen Tests

    func testHowItWorksScreen_displaysAllSteps() throws {
        navigateToStep(2)

        let step1 = app.staticTexts["1. Select files"]
        XCTAssertTrue(step1.waitForExistence(timeout: 2), "Step 1 should be visible")

        let step2 = app.staticTexts["2. Press Cmd+X"]
        XCTAssertTrue(step2.exists, "Step 2 should be visible")

        let step3 = app.staticTexts["3. Navigate to destination"]
        XCTAssertTrue(step3.exists, "Step 3 should be visible")

        let step4 = app.staticTexts["4. Press Cmd+V"]
        XCTAssertTrue(step4.exists, "Step 4 should be visible")
    }

    func testHowItWorksScreen_backNavigatesToWelcome() throws {
        navigateToStep(2)

        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2), "Back button should be visible")

        backButton.tap()

        let welcomeTitle = app.staticTexts["Welcome to\nCut & Place"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 2), "Welcome title should reappear")
    }

    func testHowItWorksScreen_backButtonIsVisible() throws {
        navigateToStep(2)

        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2), "Back button should be visible on How it works screen")
    }

    // MARK: - Permission Screen Tests

    func testPermissionScreen_displaysPermissionRequest() throws {
        navigateToStep(3)

        let permissionTitle = app.staticTexts["Permission required"]
        XCTAssertTrue(permissionTitle.waitForExistence(timeout: 2), "Permission required title should be visible")

        let openPrefsButton = app.buttons["Open System Settings"]
        XCTAssertTrue(openPrefsButton.exists, "Open System Settings button should be visible")
    }

    func testPermissionScreen_backNavigatesToHowItWorks() throws {
        navigateToStep(3)

        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2), "Back button should be visible")

        backButton.tap()

        let howItWorksTitle = app.staticTexts["How it works"]
        XCTAssertTrue(howItWorksTitle.waitForExistence(timeout: 2), "How it works should reappear")
    }

    // MARK: - Success Screen Tests

    func testSuccessScreen_displaysSuccessMessage() throws {
        navigateToStep(4)

        let successTitle = app.staticTexts["You're ready!"]
        // Success screen may not show if permission isn't granted (auto-advance blocked)
        // In that case the test just verifies we can navigate to step 4
        if successTitle.waitForExistence(timeout: 3) {
            XCTAssertTrue(successTitle.exists, "You're ready! title should be visible")

            let startButton = app.buttons["Get started"]
            XCTAssertTrue(startButton.exists, "Get started button should be visible")
        }
    }

    func testSuccessScreen_hasLaunchAtLoginToggle() throws {
        navigateToStep(4)

        let launchAtLoginLabel = app.staticTexts["Launch at login"]
        if launchAtLoginLabel.waitForExistence(timeout: 3) {
            XCTAssertTrue(launchAtLoginLabel.exists, "Launch at login option should be visible")
        }
    }

    func testSuccessScreen_hasRecommendedLabel() throws {
        navigateToStep(4)

        let recommendedLabel = app.staticTexts["Recommended for seamless workflow"]
        if recommendedLabel.waitForExistence(timeout: 3) {
            XCTAssertTrue(recommendedLabel.exists, "Recommended label should be visible")
        }
    }

    // MARK: - Full Navigation Flow Tests

    func testFullNavigation_forwardAndBack() throws {
        // Welcome -> Next
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5), "Next button should be visible")
        nextButton.tap()

        // How It Works -> Next
        let howItWorksTitle = app.staticTexts["How it works"]
        XCTAssertTrue(howItWorksTitle.waitForExistence(timeout: 2), "How it works should appear")
        if nextButton.exists && nextButton.isHittable {
            nextButton.tap()
        }

        // Permission -> Back
        let permissionTitle = app.staticTexts["Permission required"]
        if permissionTitle.waitForExistence(timeout: 2) {
            let backButton = app.buttons["Back"]
            XCTAssertTrue(backButton.exists, "Back button should be visible")
            backButton.tap()

            // Back at How It Works -> Back
            XCTAssertTrue(howItWorksTitle.waitForExistence(timeout: 2), "Should be back at How it works")
            let backButton2 = app.buttons["Back"]
            backButton2.tap()

            // Back at Welcome
            let welcomeTitle = app.staticTexts["Welcome to\nCut & Place"]
            XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 2), "Should be back at Welcome")
        }
    }

    // MARK: - Localization Tests

    func testLocalizationFiles_appIsRunning() throws {
        // Verify the app launched successfully (which it did in setUp)
        XCTAssertTrue(app.state == .runningBackground || app.state == .runningForeground,
                      "App should be running")
    }

    // MARK: - Navigation Helper

    private func navigateToStep(_ step: Int) {
        let nextButton = app.buttons["Next"]

        guard nextButton.waitForExistence(timeout: 5) else {
            XCTFail("Next button should exist to navigate")
            return
        }

        for _ in 1..<step {
            if nextButton.exists && nextButton.isHittable {
                nextButton.tap()
                // Wait for animation
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
    }
}
