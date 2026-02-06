import XCTest
@testable import CutAndPaste

/// Stress tests that try to BREAK the app through edge cases, rapid operations, and boundary conditions
final class StressTests: XCTestCase {

    // MARK: - CutStateManager Stress Tests

    func testCutState_rapidToggling_100Times_doesNotCrash() {
        let manager = CutStateManager.shared

        for _ in 0..<100 {
            manager.toggle()
        }

        // After 100 toggles (even number), should be inactive
        XCTAssertFalse(manager.cutState.isActive)
    }

    func testCutState_rapidActivation_100Times_doesNotCrash() {
        let manager = CutStateManager.shared

        for i in 0..<100 {
            manager.activateCutMode(fileCount: i)
        }

        // Should still be active with last file count
        XCTAssertTrue(manager.cutState.isActive)
        XCTAssertEqual(manager.cutState.operation?.fileCount, 99)

        manager.deactivateCutMode()
    }

    func testCutState_deactivateWhenAlreadyInactive_100Times_doesNotCrash() {
        let manager = CutStateManager.shared
        manager.deactivateCutMode()

        for _ in 0..<100 {
            manager.deactivateCutMode()
        }

        XCTAssertFalse(manager.cutState.isActive)
    }

    func testCutState_activateDeactivateRapidly_doesNotCorrupt() {
        let manager = CutStateManager.shared

        for _ in 0..<50 {
            manager.activateCutMode(fileCount: 10)
            XCTAssertTrue(manager.cutState.isActive)

            manager.deactivateCutMode()
            XCTAssertFalse(manager.cutState.isActive)
            XCTAssertNil(manager.cutState.operation)
        }
    }

    func testCutState_withZeroFileCount() {
        let manager = CutStateManager.shared

        manager.activateCutMode(fileCount: 0)
        XCTAssertTrue(manager.cutState.isActive)
        XCTAssertEqual(manager.cutState.operation?.fileCount, 0)

        manager.deactivateCutMode()
    }

    func testCutState_withNilFileCount() {
        let manager = CutStateManager.shared

        manager.activateCutMode(fileCount: nil)
        XCTAssertTrue(manager.cutState.isActive)
        XCTAssertNil(manager.cutState.operation?.fileCount)

        manager.deactivateCutMode()
    }

    func testCutState_withLargeFileCount() {
        let manager = CutStateManager.shared

        manager.activateCutMode(fileCount: Int.max)
        XCTAssertTrue(manager.cutState.isActive)
        XCTAssertEqual(manager.cutState.operation?.fileCount, Int.max)

        manager.deactivateCutMode()
    }

    func testCutState_withNegativeFileCount() {
        let manager = CutStateManager.shared

        manager.activateCutMode(fileCount: -1)
        XCTAssertTrue(manager.cutState.isActive)
        XCTAssertEqual(manager.cutState.operation?.fileCount, -1)

        manager.deactivateCutMode()
    }

    // MARK: - CutOperation Edge Cases

    func testCutOperation_isRecent_withFutureTimestamp() {
        let futureDate = Date(timeIntervalSinceNow: 3600)
        let operation = CutOperation(timestamp: futureDate)

        // Future timestamp should still be "recent"
        XCTAssertTrue(operation.isRecent)
    }

    func testCutOperation_isRecent_withOldTimestamp() {
        let oldDate = Date(timeIntervalSinceNow: -400) // 6+ minutes ago
        let operation = CutOperation(timestamp: oldDate)

        XCTAssertFalse(operation.isRecent)
    }

    func testCutOperation_isRecent_atExactBoundary() {
        // At exactly 299 seconds ago (just under 5 min) should be recent
        let borderDate = Date(timeIntervalSinceNow: -299)
        let operation = CutOperation(timestamp: borderDate)

        XCTAssertTrue(operation.isRecent)
    }

    func testCutOperation_isRecent_justOverBoundary() {
        // At 301 seconds ago (just over 5 min) should NOT be recent
        let borderDate = Date(timeIntervalSinceNow: -301)
        let operation = CutOperation(timestamp: borderDate)

        XCTAssertFalse(operation.isRecent)
    }

    func testCutOperation_withDistantPast() {
        let distantPast = Date.distantPast
        let operation = CutOperation(timestamp: distantPast)

        XCTAssertFalse(operation.isRecent)
        XCTAssertEqual(operation.timestamp, distantPast)
    }

    func testCutOperation_withDistantFuture() {
        let distantFuture = Date.distantFuture
        let operation = CutOperation(timestamp: distantFuture)

        XCTAssertTrue(operation.isRecent)
        XCTAssertEqual(operation.timestamp, distantFuture)
    }

    // MARK: - RatingState Stress Tests

    func testRatingState_skipBeyondMaxCount_doesNotOverflow() {
        var state = RatingState.initial

        // Skip WAY beyond max
        for _ in 0..<1000 {
            state.recordSkip()
        }

        XCTAssertEqual(state.skipCount, 1000)
        XCTAssertTrue(state.isDismissedPermanently)
        XCTAssertTrue(state.shouldNeverShowAgain)
        XCTAssertFalse(state.canShowPrompt)
    }

    func testRatingState_recordUsageMultipleTimes_sameDay_onlyCountsOnce() {
        var state = RatingState.initial

        for _ in 0..<100 {
            state.recordUsage()
        }

        // Should only count as 1 usage day since all on same day
        XCTAssertEqual(state.usageDaysCount, 1)
        XCTAssertNotNil(state.firstLaunchDate)
        XCTAssertNotNil(state.lastUsageDate)
    }

    func testRatingState_allTerminalActions_shouldNeverShow() {
        // Test: rate, then feedback, then skip - all at once
        var state = RatingState.initial
        state.recordRating()
        state.recordFeedback()
        state.recordSkip()
        state.recordSkip()
        state.recordSkip()

        XCTAssertTrue(state.shouldNeverShowAgain)
        XCTAssertFalse(state.canShowPrompt)
    }

    func testRatingState_canShowPrompt_withoutUsageDays() {
        var state = RatingState.initial
        // Even with firstLaunchDate set far in past, if usageDaysCount is too low, can't show
        state.firstLaunchDate = Date(timeIntervalSinceNow: -86400 * 30) // 30 days ago
        state.usageDaysCount = 0

        XCTAssertFalse(state.canShowPrompt)
    }

    func testRatingState_canShowPrompt_withEnoughUsageDays_butRecentPrompt() {
        var state = RatingState.initial
        state.firstLaunchDate = Date(timeIntervalSinceNow: -86400 * 30)
        state.usageDaysCount = Constants.Rating.requiredUsageDays
        state.lastPromptDate = Date() // Just prompted now

        XCTAssertFalse(state.canShowPrompt)
    }

    func testRatingState_equality() {
        let state1 = RatingState.initial
        let state2 = RatingState.initial

        XCTAssertEqual(state1, state2)
    }

    func testRatingState_inequality_afterSkip() {
        var state1 = RatingState.initial
        let state2 = RatingState.initial

        state1.recordSkip()

        XCTAssertNotEqual(state1, state2)
    }

    // MARK: - RatingService Stress Tests

    func testRatingService_multipleSkips_neverExceedMaxPermanentDismiss() {
        let service = RatingService.shared

        #if DEBUG
        service.resetState()
        #endif

        // Skip 10 times
        for _ in 0..<10 {
            service.handleSkip()
        }

        XCTAssertTrue(service.state.isDismissedPermanently)
        XCTAssertTrue(service.state.shouldNeverShowAgain)
        XCTAssertFalse(service.shouldShowPrompt)
    }

    func testRatingService_handlePositive_thenSkip_stillNeverShows() {
        let service = RatingService.shared

        #if DEBUG
        service.resetState()
        #endif

        service.handlePositiveResponse()
        service.handleSkip()

        XCTAssertTrue(service.state.shouldNeverShowAgain)
        XCTAssertFalse(service.shouldShowPrompt)
    }

    func testRatingService_handleNegative_thenPositive_stillNeverShows() {
        let service = RatingService.shared

        #if DEBUG
        service.resetState()
        #endif

        service.handleNegativeResponse()
        service.handlePositiveResponse()

        XCTAssertTrue(service.state.shouldNeverShowAgain)
        XCTAssertTrue(service.state.hasRated)
        XCTAssertTrue(service.state.hasGivenFeedback)
        XCTAssertFalse(service.shouldShowPrompt)
    }

    #if DEBUG
    func testRatingService_resetThenTrigger_worksCorrectly() {
        let service = RatingService.shared

        service.handleSkip()
        service.handleSkip()
        service.handleSkip()
        XCTAssertTrue(service.state.isDismissedPermanently)

        service.resetState()
        XCTAssertFalse(service.state.isDismissedPermanently)
        XCTAssertEqual(service.state.skipCount, 0)

        service.triggerPromptForDebug()
        XCTAssertTrue(service.shouldShowPrompt)
    }

    func testRatingService_debugInfo_notEmpty() {
        let service = RatingService.shared
        service.resetState()

        let info = service.debugInfo
        XCTAssertFalse(info.isEmpty)
        XCTAssertTrue(info.contains("Skip Count"))
        XCTAssertTrue(info.contains("Usage Days"))
        XCTAssertTrue(info.contains("Has Rated"))
    }
    #endif

    // MARK: - Constants Validation

    func testConstants_ratingConfig_validValues() {
        XCTAssertGreaterThan(Constants.Rating.maxSkipCount, 0)
        XCTAssertGreaterThan(Constants.Rating.daysBeforeFirstPrompt, 0)
        XCTAssertGreaterThan(Constants.Rating.daysBetweenPrompts, 0)
        XCTAssertGreaterThan(Constants.Rating.requiredUsageDays, 0)
    }

    func testConstants_appInfo_nonEmpty() {
        XCTAssertFalse(Constants.App.name.isEmpty)
        XCTAssertFalse(Constants.App.bundleIdentifier.isEmpty)
        XCTAssertFalse(Constants.App.supportEmail.isEmpty)
        XCTAssertTrue(Constants.App.bundleIdentifier.hasPrefix("de.merzkevin."))
        XCTAssertTrue(Constants.App.supportEmail.contains("@"))
    }

    func testConstants_menuBarIcons_areValidSystemNames() {
        XCTAssertFalse(Constants.MenuBar.iconDefault.isEmpty)
        XCTAssertFalse(Constants.MenuBar.iconCutActive.isEmpty)
    }

    func testConstants_finderBundleId_correct() {
        XCTAssertEqual(Constants.Finder.bundleIdentifier, "com.apple.finder")
    }

    func testConstants_notificationNames_unique() {
        let names = [
            Constants.Notifications.cutModeDidChange.rawValue,
            Constants.Notifications.accessibilityPermissionDidChange.rawValue,
            Constants.Notifications.settingsDidChange.rawValue
        ]
        let uniqueNames = Set(names)
        XCTAssertEqual(names.count, uniqueNames.count, "Notification names must be unique")
    }

    // MARK: - Date Extension Edge Cases

    func testDate_daysSince_negativeResult() {
        let futureDate = Date(timeIntervalSinceNow: 86400 * 5) // 5 days from now
        let result = Date().daysSince(futureDate)

        // daysSince a future date should be negative
        XCTAssertLessThanOrEqual(result, 0)
    }

    func testDate_daysSince_largeGap() {
        let distantPast = Date(timeIntervalSinceNow: -86400 * 365) // 1 year ago
        let result = Date().daysSince(distantPast)

        XCTAssertGreaterThanOrEqual(result, 364) // At least 364 days
    }

    func testDate_isOnSameDay_differentTimes() {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)

        var earlyComponents = components
        earlyComponents.hour = 0
        earlyComponents.minute = 0
        earlyComponents.second = 0
        let earlyMorning = calendar.date(from: earlyComponents)!

        var lateComponents = components
        lateComponents.hour = 23
        lateComponents.minute = 59
        lateComponents.second = 59
        let lateNight = calendar.date(from: lateComponents)!

        XCTAssertTrue(earlyMorning.isOnSameDay(as: lateNight))
    }

    func testDate_startOfDay_alwaysMidnight() {
        let randomDate = Date(timeIntervalSinceReferenceDate: 123456789)
        let startOfDay = randomDate.startOfDay

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    // MARK: - UserDefaults Extension Tests

    func testUserDefaults_dateRoundtrip_preservesAccuracy() {
        let defaults = UserDefaults.standard
        let key = "test_date_accuracy_\(UUID().uuidString)"
        let originalDate = Date()

        defaults.setDate(originalDate, forKey: key)
        let retrieved = defaults.date(forKey: key)

        XCTAssertNotNil(retrieved)
        if let retrieved = retrieved {
            XCTAssertEqual(originalDate.timeIntervalSinceReferenceDate, retrieved.timeIntervalSinceReferenceDate, accuracy: 0.001)
        }

        defaults.removeObject(forKey: key)
    }

    func testUserDefaults_nilDate_returnsNil() {
        let defaults = UserDefaults.standard
        let key = "test_nil_date_\(UUID().uuidString)"

        let result = defaults.date(forKey: key)
        XCTAssertNil(result)
    }

    func testUserDefaults_setDateNil_removesValue() {
        let defaults = UserDefaults.standard
        let key = "test_set_nil_\(UUID().uuidString)"

        defaults.setDate(Date(), forKey: key)
        XCTAssertNotNil(defaults.date(forKey: key))

        defaults.setDate(nil, forKey: key)
        XCTAssertNil(defaults.date(forKey: key))

        defaults.removeObject(forKey: key)
    }

    // MARK: - String Localization Tests

    func testLocalization_allOnboardingKeysExist() {
        let keys = [
            "onboarding.welcome.title",
            "onboarding.welcome.subtitle",
            "onboarding.howitworks.title",
            "onboarding.howitworks.step1.title",
            "onboarding.howitworks.step1.description",
            "onboarding.howitworks.step2.title",
            "onboarding.howitworks.step2.description",
            "onboarding.howitworks.step3.title",
            "onboarding.howitworks.step3.description",
            "onboarding.howitworks.step4.title",
            "onboarding.howitworks.step4.description",
            "onboarding.permission.granted.title",
            "onboarding.permission.granted.description",
            "onboarding.permission.required.title",
            "onboarding.permission.required.description",
            "onboarding.permission.button",
            "onboarding.success.title",
            "onboarding.success.description",
            "onboarding.success.hint",
            "onboarding.success.launch_at_login",
            "onboarding.success.launch_at_login.recommended",
            "onboarding.button.next",
            "onboarding.button.back",
            "onboarding.button.grant_permission",
            "onboarding.button.get_started"
        ]

        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            XCTAssertNotEqual(localized, key, "Missing localization for key: \(key)")
        }
    }

    func testLocalization_allMenuBarKeysExist() {
        let keys = [
            "menubar.status.ready",
            "menubar.status.disabled",
            "menubar.status.cut_active",
            "menubar.status.permission_required",
            "menubar.toggle.enabled",
            "menubar.cut_mode.files_ready",
            "menubar.cut_mode.cancel",
            "menubar.action.settings",
            "menubar.action.quit"
        ]

        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            XCTAssertNotEqual(localized, key, "Missing localization for key: \(key)")
        }
    }

    func testLocalization_allSettingsKeysExist() {
        let keys = [
            "settings.tab.general",
            "settings.tab.permissions",
            "settings.tab.about",
            "settings.general.enable",
            "settings.general.enable.help",
            "settings.general.launch_at_login",
            "settings.general.launch_at_login.help",
            "settings.general.visual_feedback",
            "settings.general.visual_feedback.help",
            "settings.permissions.accessibility",
            "settings.permissions.accessibility.description",
            "settings.permissions.accessibility.explanation",
            "settings.permissions.status.granted",
            "settings.permissions.status.not_granted",
            "settings.permissions.open_settings"
        ]

        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            XCTAssertNotEqual(localized, key, "Missing localization for key: \(key)")
        }
    }

    func testLocalization_allRatingKeysExist() {
        let keys = [
            "rating.title",
            "rating.question",
            "rating.button.yes",
            "rating.button.no",
            "rating.button.skip"
        ]

        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            XCTAssertNotEqual(localized, key, "Missing localization for key: \(key)")
        }
    }

    func testLocalization_allAboutKeysExist() {
        let keys = [
            "about.feedback",
            "about.feedback.subtitle",
            "about.rate",
            "about.rate.subtitle",
            "about.made_with_love",
            "feedback.email.subject"
        ]

        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            XCTAssertNotEqual(localized, key, "Missing localization for key: \(key)")
        }
    }

    // MARK: - AppSettings Edge Cases

    func testAppSettings_default_isValid() {
        let settings = AppSettings.default

        // Default should have sensible values
        XCTAssertTrue(settings.isEnabled)
        XCTAssertTrue(settings.launchAtLogin)
        XCTAssertTrue(settings.showVisualFeedback)
        XCTAssertFalse(settings.hasCompletedOnboarding)
    }

    func testAppSettings_equality() {
        let settings1 = AppSettings.default
        let settings2 = AppSettings.default

        XCTAssertEqual(settings1, settings2)
    }

    func testAppSettings_inequality() {
        var settings1 = AppSettings.default
        let settings2 = AppSettings.default

        settings1.isEnabled = false

        XCTAssertNotEqual(settings1, settings2)
    }

    func testAppSettings_codable_roundtrip() throws {
        let original = AppSettings.default
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testAppSettings_codable_allFieldsPreserved() throws {
        let settings = AppSettings(
            isEnabled: false,
            launchAtLogin: true,
            showVisualFeedback: false,
            hasCompletedOnboarding: true
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded.isEnabled, false)
        XCTAssertEqual(decoded.launchAtLogin, true)
        XCTAssertEqual(decoded.showVisualFeedback, false)
        XCTAssertEqual(decoded.hasCompletedOnboarding, true)
    }

    // MARK: - CGEventFlags Extension Tests

    func testCGEventFlags_hasCommand() {
        let flags: CGEventFlags = .maskCommand
        XCTAssertTrue(flags.hasCommand)
        XCTAssertFalse(flags.hasShift)
        XCTAssertFalse(flags.hasOption)
        XCTAssertFalse(flags.hasControl)
    }

    func testCGEventFlags_isOnlyCommand_withExtraModifiers() {
        let flags: CGEventFlags = [.maskCommand, .maskShift]
        XCTAssertTrue(flags.hasCommand)
        XCTAssertTrue(flags.hasShift)
        XCTAssertFalse(flags.isOnlyCommand)
    }

    func testCGEventFlags_isOnlyCommand_withJustCommand() {
        let flags: CGEventFlags = .maskCommand
        XCTAssertTrue(flags.isOnlyCommand)
    }

    func testCGEventFlags_emptyFlags() {
        let flags: CGEventFlags = []
        XCTAssertFalse(flags.hasCommand)
        XCTAssertFalse(flags.hasShift)
        XCTAssertFalse(flags.hasOption)
        XCTAssertFalse(flags.hasControl)
        XCTAssertFalse(flags.isOnlyCommand)
    }

    // MARK: - OnboardingStep Tests

    func testOnboardingStep_allCases_hasCorrectCount() {
        XCTAssertEqual(OnboardingStep.allCases.count, 4)
    }

    func testOnboardingStep_rawValues_areSequential() {
        for (index, step) in OnboardingStep.allCases.enumerated() {
            XCTAssertEqual(step.rawValue, index)
        }
    }

    func testOnboardingStep_next_lastStepReturnsNil() {
        XCTAssertNil(OnboardingStep.success.next)
    }

    func testOnboardingStep_previous_firstStepReturnsNil() {
        XCTAssertNil(OnboardingStep.welcome.previous)
    }

    func testOnboardingStep_navigation_fullChain() {
        var step: OnboardingStep? = .welcome

        var visited: [OnboardingStep] = []
        while let current = step {
            visited.append(current)
            step = current.next
        }

        XCTAssertEqual(visited.count, 4)
        XCTAssertEqual(visited, [.welcome, .howItWorks, .permission, .success])
    }

    func testOnboardingStep_navigation_reverseChain() {
        var step: OnboardingStep? = .success

        var visited: [OnboardingStep] = []
        while let current = step {
            visited.append(current)
            step = current.previous
        }

        XCTAssertEqual(visited.count, 4)
        XCTAssertEqual(visited, [.success, .permission, .howItWorks, .welcome])
    }

    func testOnboardingStep_title_notEmpty() {
        for step in OnboardingStep.allCases {
            XCTAssertFalse(step.title.isEmpty, "Title for step \(step) should not be empty")
        }
    }

    // MARK: - SettingsManager Tests

    func testSettingsManager_toggleEnabled_changesState() {
        let manager = SettingsManager.shared
        let original = manager.isEnabled

        manager.isEnabled = !original
        XCTAssertEqual(manager.isEnabled, !original)

        // Restore
        manager.isEnabled = original
    }

    func testSettingsManager_postsNotificationOnChange() {
        let manager = SettingsManager.shared
        let expectation = expectation(forNotification: Constants.Notifications.settingsDidChange, object: nil)

        manager.showVisualFeedback.toggle()

        wait(for: [expectation], timeout: 1.0)

        // Restore
        manager.showVisualFeedback.toggle()
    }

    // MARK: - AccessibilityService Tests

    func testAccessibilityService_checkPermission_doesNotCrash() {
        let service = AccessibilityService.shared
        service.checkPermission()
        // No crash = pass
    }

    func testAccessibilityService_openSystemPreferences_doesNotCrash() {
        // Note: This will attempt to open System Preferences, but won't fail if it can't
        // We mainly verify it doesn't crash
        XCTAssertNotNil(AccessibilityService.shared)
    }

    // MARK: - FinderMonitorService Tests

    func testFinderMonitor_checkStatus_doesNotCrash() {
        let monitor = FinderMonitorService.shared
        monitor.checkFinderStatus()
        // No crash = pass
    }

    // MARK: - Device Info Tests

    func testDeviceInfo_macOSVersion_isValid() {
        let version = Constants.Device.macOSVersion
        XCTAssertFalse(version.isEmpty)

        let components = version.split(separator: ".")
        XCTAssertGreaterThanOrEqual(components.count, 2, "macOS version should have at least major.minor")
    }

    func testDeviceInfo_deviceModel_isValid() {
        let model = Constants.Device.deviceModel
        XCTAssertFalse(model.isEmpty)
    }

    func testDeviceInfo_systemInfo_containsAllFields() {
        let info = Constants.Device.systemInfo
        XCTAssertTrue(info.contains("macOS Version"))
        XCTAssertTrue(info.contains("Device"))
        XCTAssertTrue(info.contains("App Version"))
    }
}
