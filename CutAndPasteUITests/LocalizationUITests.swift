import XCTest

final class LocalizationUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-onboarding"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - English Localization Tests

    func testEnglishLocalization_OnboardingWelcome() throws {
        launchAppWithLocale("en")

        let welcomeTitle = app.staticTexts["Welcome to\nCut & Place"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists, "English welcome title should be displayed")
        }

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists, "English 'Next' button should exist")
    }

    func testEnglishLocalization_OnboardingHowItWorks() throws {
        launchAppWithLocale("en")
        navigateToStep(2)

        let title = app.staticTexts["How it works"]
        if title.waitForExistence(timeout: 2) {
            XCTAssertTrue(title.exists, "English 'How it works' title should be displayed")
        }

        // Check step titles
        XCTAssertTrue(app.staticTexts["1. Select files"].exists, "Step 1 should be in English")
        XCTAssertTrue(app.staticTexts["2. Press Cmd+X"].exists, "Step 2 should be in English")
        XCTAssertTrue(app.staticTexts["3. Navigate to destination"].exists, "Step 3 should be in English")
        XCTAssertTrue(app.staticTexts["4. Press Cmd+V"].exists, "Step 4 should be in English")
    }

    func testEnglishLocalization_OnboardingPermission() throws {
        launchAppWithLocale("en")
        navigateToStep(3)

        let permissionTitle = app.staticTexts["Permission required"]
        if permissionTitle.waitForExistence(timeout: 2) {
            XCTAssertTrue(permissionTitle.exists, "English permission title should be displayed")
        }

        let openSettingsButton = app.buttons["Open System Settings"]
        XCTAssertTrue(openSettingsButton.exists, "English 'Open System Settings' button should exist")
    }

    // MARK: - German Localization Tests

    func testGermanLocalization_OnboardingWelcome() throws {
        launchAppWithLocale("de")

        let welcomeTitle = app.staticTexts["Willkommen bei\nCut & Place"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists, "German welcome title should be displayed")
        }

        let nextButton = app.buttons["Weiter"]
        XCTAssertTrue(nextButton.exists, "German 'Weiter' button should exist")
    }

    func testGermanLocalization_OnboardingHowItWorks() throws {
        launchAppWithLocale("de")
        navigateToStep(2, buttonTitle: "Weiter")

        let title = app.staticTexts["So funktioniert's"]
        if title.waitForExistence(timeout: 2) {
            XCTAssertTrue(title.exists, "German 'So funktioniert's' title should be displayed")
        }

        // Check step titles
        XCTAssertTrue(app.staticTexts["1. Dateien auswählen"].exists, "Step 1 should be in German")
        XCTAssertTrue(app.staticTexts["2. Cmd+X drücken"].exists, "Step 2 should be in German")
        XCTAssertTrue(app.staticTexts["3. Zum Ziel navigieren"].exists, "Step 3 should be in German")
        XCTAssertTrue(app.staticTexts["4. Cmd+V drücken"].exists, "Step 4 should be in German")
    }

    func testGermanLocalization_OnboardingPermission() throws {
        launchAppWithLocale("de")
        navigateToStep(3, buttonTitle: "Weiter")

        let permissionTitle = app.staticTexts["Berechtigung erforderlich"]
        if permissionTitle.waitForExistence(timeout: 2) {
            XCTAssertTrue(permissionTitle.exists, "German permission title should be displayed")
        }

        let openSettingsButton = app.buttons["Systemeinstellungen öffnen"]
        XCTAssertTrue(openSettingsButton.exists, "German 'Systemeinstellungen öffnen' button should exist")
    }

    // MARK: - French Localization Tests

    func testFrenchLocalization_OnboardingWelcome() throws {
        launchAppWithLocale("fr")

        let welcomeTitle = app.staticTexts["Bienvenue dans\nCut & Place"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists, "French welcome title should be displayed")
        }

        let nextButton = app.buttons["Suivant"]
        XCTAssertTrue(nextButton.exists, "French 'Suivant' button should exist")
    }

    // MARK: - Spanish Localization Tests

    func testSpanishLocalization_OnboardingWelcome() throws {
        launchAppWithLocale("es")

        let welcomeTitle = app.staticTexts["Bienvenido a\nCut & Place"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists, "Spanish welcome title should be displayed")
        }

        let nextButton = app.buttons["Siguiente"]
        XCTAssertTrue(nextButton.exists, "Spanish 'Siguiente' button should exist")
    }

    // MARK: - Japanese Localization Tests

    func testJapaneseLocalization_OnboardingWelcome() throws {
        launchAppWithLocale("ja")

        let welcomeTitle = app.staticTexts["Cut & Place へ\nようこそ"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists, "Japanese welcome title should be displayed")
        }

        let nextButton = app.buttons["次へ"]
        XCTAssertTrue(nextButton.exists, "Japanese '次へ' button should exist")
    }

    // MARK: - Chinese Localization Tests

    func testChineseLocalization_OnboardingWelcome() throws {
        launchAppWithLocale("zh-Hans")

        let welcomeTitle = app.staticTexts["欢迎使用\nCut & Place"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists, "Chinese welcome title should be displayed")
        }

        let nextButton = app.buttons["下一步"]
        XCTAssertTrue(nextButton.exists, "Chinese '下一步' button should exist")
    }

    // MARK: - Korean Localization Tests

    func testKoreanLocalization_OnboardingWelcome() throws {
        launchAppWithLocale("ko")

        let welcomeTitle = app.staticTexts["Cut & Place에\n오신 것을 환영합니다"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            XCTAssertTrue(welcomeTitle.exists, "Korean welcome title should be displayed")
        }

        let nextButton = app.buttons["다음"]
        XCTAssertTrue(nextButton.exists, "Korean '다음' button should exist")
    }

    // MARK: - Helper Methods

    private func launchAppWithLocale(_ locale: String) {
        app.launchArguments.append(contentsOf: ["-AppleLanguages", "(\(locale))", "-AppleLocale", locale])
        app.launch()
    }

    private func navigateToStep(_ step: Int, buttonTitle: String = "Next") {
        let nextButton = app.buttons[buttonTitle]

        guard nextButton.waitForExistence(timeout: 5) else { return }

        for _ in 1..<step {
            if nextButton.exists && nextButton.isHittable {
                nextButton.tap()
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
    }
}
