import XCTest
@testable import CutAndPaste

final class IntegrationTests: XCTestCase {

    // MARK: - Settings Manager Tests

    func testSettingsManager_defaultSettings() {
        let settings = AppSettings.default

        XCTAssertTrue(settings.isEnabled)
        XCTAssertFalse(settings.launchAtLogin)
        XCTAssertTrue(settings.showVisualFeedback)
        XCTAssertFalse(settings.hasCompletedOnboarding)
    }

    func testSettingsManager_singleton() {
        let instance1 = SettingsManager.shared
        let instance2 = SettingsManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Finder Monitor Tests

    func testFinderMonitorService_singleton() {
        let instance1 = FinderMonitorService.shared
        let instance2 = FinderMonitorService.shared
        XCTAssertTrue(instance1 === instance2)
    }

    func testFinderMonitorService_checkFinderStatus_doesNotCrash() {
        let monitor = FinderMonitorService.shared
        monitor.checkFinderStatus()
        // Should not crash
    }

    // MARK: - Accessibility Service Tests

    func testAccessibilityService_singleton() {
        let instance1 = AccessibilityService.shared
        let instance2 = AccessibilityService.shared
        XCTAssertTrue(instance1 === instance2)
    }

    func testAccessibilityService_checkPermission_doesNotCrash() {
        let service = AccessibilityService.shared
        service.checkPermission()
        // Should not crash
    }

    // MARK: - Onboarding Manager Tests

    func testOnboardingManager_singleton() {
        let instance1 = OnboardingManager.shared
        let instance2 = OnboardingManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    func testOnboardingStep_values() {
        XCTAssertEqual(OnboardingStep.welcome.rawValue, 0)
        XCTAssertEqual(OnboardingStep.howItWorks.rawValue, 1)
        XCTAssertEqual(OnboardingStep.permission.rawValue, 2)
        XCTAssertEqual(OnboardingStep.success.rawValue, 3)
    }

    func testOnboardingStep_titles() {
        XCTAssertEqual(OnboardingStep.welcome.title, "Willkommen")
        XCTAssertEqual(OnboardingStep.howItWorks.title, "So funktioniert's")
        XCTAssertEqual(OnboardingStep.permission.title, "Berechtigung")
        XCTAssertEqual(OnboardingStep.success.title, "Fertig")
    }

    func testOnboardingStep_navigation() {
        XCTAssertTrue(OnboardingStep.welcome.isFirst)
        XCTAssertFalse(OnboardingStep.welcome.isLast)

        XCTAssertFalse(OnboardingStep.success.isFirst)
        XCTAssertTrue(OnboardingStep.success.isLast)

        XCTAssertEqual(OnboardingStep.welcome.next, .howItWorks)
        XCTAssertEqual(OnboardingStep.howItWorks.next, .permission)
        XCTAssertEqual(OnboardingStep.permission.next, .success)
        XCTAssertNil(OnboardingStep.success.next)

        XCTAssertNil(OnboardingStep.welcome.previous)
        XCTAssertEqual(OnboardingStep.howItWorks.previous, .welcome)
    }

    // MARK: - Constants Tests

    func testConstants_appInfo() {
        XCTAssertEqual(Constants.App.name, "Cut & Paste")
        XCTAssertEqual(Constants.App.bundleIdentifier, "com.kevinmerz.cutandpaste")
        XCTAssertEqual(Constants.App.supportEmail, "MerzKevin@me.com")
    }

    func testConstants_ratingConfig() {
        XCTAssertEqual(Constants.Rating.maxSkipCount, 3)
        XCTAssertGreaterThan(Constants.Rating.daysBeforeFirstPrompt, 0)
        XCTAssertGreaterThan(Constants.Rating.daysBetweenPrompts, 0)
        XCTAssertGreaterThan(Constants.Rating.requiredUsageDays, 0)
    }

    func testConstants_finder() {
        XCTAssertEqual(Constants.Finder.bundleIdentifier, "com.apple.finder")
    }

    func testConstants_menuBar() {
        XCTAssertEqual(Constants.MenuBar.iconDefault, "scissors")
        XCTAssertEqual(Constants.MenuBar.iconCutActive, "scissors.badge.ellipsis")
    }

    // MARK: - Date Extension Tests

    func testDate_startOfDay() {
        let now = Date()
        let startOfDay = now.startOfDay

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testDate_isOnSameDay() {
        let date1 = Date()
        let date2 = Date()

        XCTAssertTrue(date1.isOnSameDay(as: date2))
    }

    func testDate_daysSince_sameDay() {
        let now = Date()
        let daysSince = now.daysSince(now)

        XCTAssertEqual(daysSince, 0)
    }

    // MARK: - UserDefaults Extension Tests

    func testUserDefaults_dateStorage() {
        let defaults = UserDefaults.standard
        let testKey = "testDateKey_\(UUID().uuidString)"
        let testDate = Date()

        defaults.setDate(testDate, forKey: testKey)
        let retrievedDate = defaults.date(forKey: testKey)

        XCTAssertNotNil(retrievedDate)

        // Clean up
        defaults.removeObject(forKey: testKey)
    }

    // MARK: - Full Flow Integration

    func testRatingFlow_skipThreeTimes_neverShowsAgain() {
        let ratingService = RatingService.shared

        #if DEBUG
        ratingService.resetState()
        #endif

        // Skip three times
        for i in 0..<Constants.Rating.maxSkipCount {
            ratingService.handleSkip()
            XCTAssertEqual(ratingService.state.skipCount, i + 1)
        }

        // After max skips
        XCTAssertTrue(ratingService.state.isDismissedPermanently)
        XCTAssertTrue(ratingService.state.shouldNeverShowAgain)

        // One more skip should not change anything
        let previousSkipCount = ratingService.state.skipCount
        ratingService.handleSkip()
        XCTAssertEqual(ratingService.state.skipCount, previousSkipCount + 1) // Count still increases
        XCTAssertTrue(ratingService.state.shouldNeverShowAgain) // But still never show
    }

    func testCutStateFlow_activateDeactivate() {
        let cutStateManager = CutStateManager.shared

        // Start inactive
        cutStateManager.deactivateCutMode()
        XCTAssertFalse(cutStateManager.cutState.isActive)

        // Activate
        cutStateManager.activateCutMode()
        XCTAssertTrue(cutStateManager.cutState.isActive)
        XCTAssertNotNil(cutStateManager.cutState.operation)

        // Deactivate
        cutStateManager.deactivateCutMode()
        XCTAssertFalse(cutStateManager.cutState.isActive)
        XCTAssertNil(cutStateManager.cutState.operation)
    }
}
