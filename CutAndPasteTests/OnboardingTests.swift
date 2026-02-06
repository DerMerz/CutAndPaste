import XCTest
import Combine
@testable import CutAndPaste

// MARK: - OnboardingManager Unit Tests

final class OnboardingManagerTests: XCTestCase {

    private var manager: OnboardingManager!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        manager = OnboardingManager.shared
        #if DEBUG
        manager.reset()
        #endif
    }

    override func tearDown() {
        cancellables.removeAll()
        #if DEBUG
        manager.reset()
        #endif
        manager = nil
        super.tearDown()
    }

    // MARK: - Singleton

    func testSingleton_returnsSameInstance() {
        let a = OnboardingManager.shared
        let b = OnboardingManager.shared
        XCTAssertTrue(a === b)
    }

    // MARK: - Initial State

    func testInitialState_currentStepIsWelcome() {
        XCTAssertEqual(manager.currentStep, .welcome)
    }

    func testInitialState_isOnboardingCompleteMatchesSettings() {
        // After reset, isOnboardingComplete should be false
        // (reset sets it to false)
        XCTAssertFalse(manager.isOnboardingComplete)
    }

    // MARK: - start()

    func testStart_resetsToWelcome() {
        manager.goToStep(.permission)
        XCTAssertEqual(manager.currentStep, .permission)

        manager.start()
        XCTAssertEqual(manager.currentStep, .welcome)
    }

    func testStart_fromSuccess_resetsToWelcome() {
        manager.goToStep(.success)
        manager.start()
        XCTAssertEqual(manager.currentStep, .welcome)
    }

    // MARK: - next()

    func testNext_fromWelcome_goesToHowItWorks() {
        XCTAssertEqual(manager.currentStep, .welcome)
        manager.next()
        XCTAssertEqual(manager.currentStep, .howItWorks)
    }

    func testNext_fromHowItWorks_goesToPermission() {
        manager.goToStep(.howItWorks)
        manager.next()
        XCTAssertEqual(manager.currentStep, .permission)
    }

    func testNext_fromPermission_goesToSuccess() {
        manager.goToStep(.permission)
        manager.next()
        XCTAssertEqual(manager.currentStep, .success)
    }

    func testNext_fromSuccess_callsComplete() {
        manager.goToStep(.success)
        XCTAssertFalse(manager.isOnboardingComplete)

        manager.next()

        XCTAssertTrue(manager.isOnboardingComplete)
    }

    func testNext_fullChain_welcomeToComplete() {
        XCTAssertEqual(manager.currentStep, .welcome)

        manager.next()
        XCTAssertEqual(manager.currentStep, .howItWorks)

        manager.next()
        XCTAssertEqual(manager.currentStep, .permission)

        manager.next()
        XCTAssertEqual(manager.currentStep, .success)

        manager.next()
        XCTAssertTrue(manager.isOnboardingComplete)
    }

    // MARK: - previous()

    func testPrevious_fromWelcome_staysAtWelcome() {
        XCTAssertEqual(manager.currentStep, .welcome)
        manager.previous()
        XCTAssertEqual(manager.currentStep, .welcome)
    }

    func testPrevious_fromHowItWorks_goesToWelcome() {
        manager.goToStep(.howItWorks)
        manager.previous()
        XCTAssertEqual(manager.currentStep, .welcome)
    }

    func testPrevious_fromPermission_goesToHowItWorks() {
        manager.goToStep(.permission)
        manager.previous()
        XCTAssertEqual(manager.currentStep, .howItWorks)
    }

    func testPrevious_fromSuccess_goesToPermission() {
        manager.goToStep(.success)
        manager.previous()
        XCTAssertEqual(manager.currentStep, .permission)
    }

    func testPrevious_fullChain_successToWelcome() {
        manager.goToStep(.success)

        manager.previous()
        XCTAssertEqual(manager.currentStep, .permission)

        manager.previous()
        XCTAssertEqual(manager.currentStep, .howItWorks)

        manager.previous()
        XCTAssertEqual(manager.currentStep, .welcome)

        manager.previous()
        XCTAssertEqual(manager.currentStep, .welcome) // stays at welcome
    }

    // MARK: - goToStep()

    func testGoToStep_setsCurrentStep() {
        for step in OnboardingStep.allCases {
            manager.goToStep(step)
            XCTAssertEqual(manager.currentStep, step)
        }
    }

    func testGoToStep_sameStep_noChange() {
        manager.goToStep(.permission)
        XCTAssertEqual(manager.currentStep, .permission)
        manager.goToStep(.permission)
        XCTAssertEqual(manager.currentStep, .permission)
    }

    // MARK: - complete()

    func testComplete_setsIsOnboardingCompleteToTrue() {
        XCTAssertFalse(manager.isOnboardingComplete)
        manager.complete()
        XCTAssertTrue(manager.isOnboardingComplete)
    }

    func testComplete_persistsToSettingsManager() {
        manager.complete()
        XCTAssertTrue(SettingsManager.shared.hasCompletedOnboarding)
    }

    func testComplete_calledTwice_doesNotCrash() {
        manager.complete()
        XCTAssertTrue(manager.isOnboardingComplete)
        manager.complete()
        XCTAssertTrue(manager.isOnboardingComplete)
    }

    // MARK: - needsOnboarding

    func testNeedsOnboarding_beforeComplete_returnsTrue() {
        #if DEBUG
        manager.reset()
        SettingsManager.shared.hasCompletedOnboarding = false
        #endif
        XCTAssertTrue(manager.needsOnboarding)
    }

    func testNeedsOnboarding_afterComplete_returnsFalse() {
        manager.complete()
        XCTAssertFalse(manager.needsOnboarding)
    }

    // MARK: - isPermissionGranted

    func testIsPermissionGranted_matchesAccessibilityService() {
        let expected = AccessibilityService.shared.isAccessibilityEnabled
        XCTAssertEqual(manager.isPermissionGranted, expected)
    }

    // MARK: - Combine Publishers

    func testCurrentStep_publishesChanges() {
        let expectation = expectation(description: "currentStep publishes")
        var receivedSteps: [OnboardingStep] = []

        manager.$currentStep
            .dropFirst() // ignore initial
            .sink { step in
                receivedSteps.append(step)
                if receivedSteps.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        manager.next() // -> howItWorks
        manager.next() // -> permission
        manager.next() // -> success

        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedSteps, [.howItWorks, .permission, .success])
    }

    func testIsOnboardingComplete_publishesOnComplete() {
        let expectation = expectation(description: "isOnboardingComplete publishes")

        manager.$isOnboardingComplete
            .dropFirst()
            .filter { $0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        manager.complete()

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - reset() (DEBUG only)

    #if DEBUG
    func testReset_resetsStepToWelcome() {
        manager.goToStep(.success)
        manager.reset()
        XCTAssertEqual(manager.currentStep, .welcome)
    }

    func testReset_resetsIsOnboardingComplete() {
        manager.complete()
        XCTAssertTrue(manager.isOnboardingComplete)
        manager.reset()
        XCTAssertFalse(manager.isOnboardingComplete)
    }
    #endif
}

// MARK: - OnboardingViewModel Unit Tests

final class OnboardingViewModelTests: XCTestCase {

    private var viewModel: OnboardingViewModel!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        #if DEBUG
        OnboardingManager.shared.reset()
        SettingsManager.shared.hasCompletedOnboarding = false
        #endif
        viewModel = OnboardingViewModel()
    }

    override func tearDown() {
        cancellables.removeAll()
        #if DEBUG
        OnboardingManager.shared.reset()
        #endif
        viewModel = nil
        super.tearDown()
    }

    // MARK: - progress

    func testProgress_atWelcome_isZero() {
        XCTAssertEqual(viewModel.progress, 0.0, accuracy: 0.001)
    }

    func testProgress_atHowItWorks_isOneThird() {
        OnboardingManager.shared.goToStep(.howItWorks)
        // Wait for Combine binding to update
        let expectation = expectation(description: "progress updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.progress, 1.0 / 3.0, accuracy: 0.001)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testProgress_atPermission_isTwoThirds() {
        OnboardingManager.shared.goToStep(.permission)
        let expectation = expectation(description: "progress updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.progress, 2.0 / 3.0, accuracy: 0.001)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testProgress_atSuccess_isOne() {
        OnboardingManager.shared.goToStep(.success)
        let expectation = expectation(description: "progress updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.progress, 1.0, accuracy: 0.001)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - canGoBack

    func testCanGoBack_atWelcome_isFalse() {
        XCTAssertFalse(viewModel.canGoBack)
    }

    func testCanGoBack_atHowItWorks_isTrue() {
        OnboardingManager.shared.goToStep(.howItWorks)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.canGoBack)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testCanGoBack_atPermission_isTrue() {
        OnboardingManager.shared.goToStep(.permission)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.canGoBack)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testCanGoBack_atSuccess_isTrue() {
        OnboardingManager.shared.goToStep(.success)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.canGoBack)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - canGoNext

    func testCanGoNext_atWelcome_isTrue() {
        XCTAssertTrue(viewModel.canGoNext)
    }

    func testCanGoNext_atHowItWorks_isTrue() {
        OnboardingManager.shared.goToStep(.howItWorks)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.canGoNext)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testCanGoNext_atPermission_dependsOnPermission() {
        OnboardingManager.shared.goToStep(.permission)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // canGoNext should match permission state
            let expected = AccessibilityService.shared.isAccessibilityEnabled
            XCTAssertEqual(self.viewModel.canGoNext, expected)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testCanGoNext_atSuccess_isTrue() {
        OnboardingManager.shared.goToStep(.success)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.canGoNext)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - nextButtonTitle

    func testNextButtonTitle_atWelcome_isNext() {
        let title = viewModel.nextButtonTitle
        XCTAssertEqual(title, "onboarding.button.next".localized)
    }

    func testNextButtonTitle_atHowItWorks_isNext() {
        OnboardingManager.shared.goToStep(.howItWorks)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.nextButtonTitle, "onboarding.button.next".localized)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testNextButtonTitle_atPermission_dependsOnPermission() {
        OnboardingManager.shared.goToStep(.permission)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.viewModel.isPermissionGranted {
                XCTAssertEqual(self.viewModel.nextButtonTitle, "onboarding.button.next".localized)
            } else {
                XCTAssertEqual(self.viewModel.nextButtonTitle, "onboarding.button.grant_permission".localized)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testNextButtonTitle_atSuccess_isGetStarted() {
        OnboardingManager.shared.goToStep(.success)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.nextButtonTitle, "onboarding.button.get_started".localized)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - next()

    func testNext_atWelcome_advancesToHowItWorks() {
        viewModel.next()
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.currentStep, .howItWorks)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testNext_atHowItWorks_advancesToPermission() {
        OnboardingManager.shared.goToStep(.howItWorks)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.viewModel.next()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(self.viewModel.currentStep, .permission)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - previous()

    func testPrevious_delegatesToManager() {
        OnboardingManager.shared.goToStep(.howItWorks)
        let expectation = expectation(description: "step updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.previous()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(self.viewModel.currentStep, .welcome)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - complete()

    func testComplete_delegatesToManager() {
        viewModel.complete()
        XCTAssertTrue(OnboardingManager.shared.isOnboardingComplete)
    }

    // MARK: - updateLaunchAtLogin()

    func testUpdateLaunchAtLogin_updatesLocalState() {
        let original = viewModel.launchAtLogin
        viewModel.updateLaunchAtLogin(!original)
        XCTAssertEqual(viewModel.launchAtLogin, !original)

        // Restore
        viewModel.updateLaunchAtLogin(original)
    }

    func testUpdateLaunchAtLogin_persistsToSettingsManager() {
        let original = SettingsManager.shared.launchAtLogin
        viewModel.updateLaunchAtLogin(!original)
        XCTAssertEqual(SettingsManager.shared.launchAtLogin, !original)

        // Restore
        viewModel.updateLaunchAtLogin(original)
    }

    func testUpdateLaunchAtLogin_toggleMultipleTimes() {
        let original = viewModel.launchAtLogin
        for i in 0..<10 {
            let newValue = i % 2 == 0
            viewModel.updateLaunchAtLogin(newValue)
            XCTAssertEqual(viewModel.launchAtLogin, newValue)
            XCTAssertEqual(SettingsManager.shared.launchAtLogin, newValue)
        }

        // Restore
        viewModel.updateLaunchAtLogin(original)
    }

    // MARK: - isCheckingPermission

    func testIsCheckingPermission_initiallyFalse() {
        XCTAssertFalse(viewModel.isCheckingPermission)
    }

    // MARK: - isPermissionGranted

    func testIsPermissionGranted_matchesAccessibilityService() {
        let expected = AccessibilityService.shared.isAccessibilityEnabled
        let expectation = expectation(description: "permission syncs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.viewModel.isPermissionGranted, expected)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Binding: currentStep mirrors manager

    func testBinding_currentStepMirrorsManager() {
        let expectation = expectation(description: "step syncs")

        OnboardingManager.shared.goToStep(.permission)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.viewModel.currentStep, .permission)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - OnboardingStep Exhaustive Tests

final class OnboardingStepTests: XCTestCase {

    func testAllCases_count() {
        XCTAssertEqual(OnboardingStep.allCases.count, 4)
    }

    func testRawValues_sequential() {
        for (index, step) in OnboardingStep.allCases.enumerated() {
            XCTAssertEqual(step.rawValue, index, "Step \(step) rawValue should be \(index)")
        }
    }

    func testIsFirst_onlyWelcome() {
        for step in OnboardingStep.allCases {
            if step == .welcome {
                XCTAssertTrue(step.isFirst, "\(step) should be first")
            } else {
                XCTAssertFalse(step.isFirst, "\(step) should not be first")
            }
        }
    }

    func testIsLast_onlySuccess() {
        for step in OnboardingStep.allCases {
            if step == .success {
                XCTAssertTrue(step.isLast, "\(step) should be last")
            } else {
                XCTAssertFalse(step.isLast, "\(step) should not be last")
            }
        }
    }

    func testNext_returnsCorrectStep() {
        XCTAssertEqual(OnboardingStep.welcome.next, .howItWorks)
        XCTAssertEqual(OnboardingStep.howItWorks.next, .permission)
        XCTAssertEqual(OnboardingStep.permission.next, .success)
        XCTAssertNil(OnboardingStep.success.next)
    }

    func testPrevious_returnsCorrectStep() {
        XCTAssertNil(OnboardingStep.welcome.previous)
        XCTAssertEqual(OnboardingStep.howItWorks.previous, .welcome)
        XCTAssertEqual(OnboardingStep.permission.previous, .howItWorks)
        XCTAssertEqual(OnboardingStep.success.previous, .permission)
    }

    func testTitle_allNonEmpty() {
        for step in OnboardingStep.allCases {
            XCTAssertFalse(step.title.isEmpty, "Title for \(step) should not be empty")
        }
    }

    func testTitle_allDistinct() {
        let titles = OnboardingStep.allCases.map { $0.title }
        let uniqueTitles = Set(titles)
        XCTAssertEqual(titles.count, uniqueTitles.count, "All step titles should be distinct")
    }

    func testForwardChain_visitsAllSteps() {
        var step: OnboardingStep? = .welcome
        var visited: [OnboardingStep] = []

        while let current = step {
            visited.append(current)
            step = current.next
        }

        XCTAssertEqual(visited, OnboardingStep.allCases)
    }

    func testReverseChain_visitsAllSteps() {
        var step: OnboardingStep? = .success
        var visited: [OnboardingStep] = []

        while let current = step {
            visited.append(current)
            step = current.previous
        }

        XCTAssertEqual(visited, OnboardingStep.allCases.reversed())
    }

    func testNext_then_previous_returnsOriginal() {
        for step in OnboardingStep.allCases {
            if let next = step.next, let back = next.previous {
                XCTAssertEqual(back, step, "Going next then previous from \(step) should return to \(step)")
            }
        }
    }

    func testPrevious_then_next_returnsOriginal() {
        for step in OnboardingStep.allCases {
            if let prev = step.previous, let forward = prev.next {
                XCTAssertEqual(forward, step, "Going previous then next from \(step) should return to \(step)")
            }
        }
    }
}

// MARK: - Onboarding State Persistence Tests

final class OnboardingPersistenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        #if DEBUG
        OnboardingManager.shared.reset()
        SettingsManager.shared.hasCompletedOnboarding = false
        #endif
    }

    override func tearDown() {
        #if DEBUG
        OnboardingManager.shared.reset()
        SettingsManager.shared.hasCompletedOnboarding = false
        #endif
        super.tearDown()
    }

    func testCompleteOnboarding_persistsInUserDefaults() {
        XCTAssertFalse(SettingsManager.shared.hasCompletedOnboarding)
        OnboardingManager.shared.complete()
        XCTAssertTrue(SettingsManager.shared.hasCompletedOnboarding)
    }

    func testCompleteOnboarding_needsOnboarding_returnsFalse() {
        OnboardingManager.shared.complete()
        XCTAssertFalse(OnboardingManager.shared.needsOnboarding)
    }

    func testDefaultAppSettings_onboardingNotComplete() {
        let defaults = AppSettings.default
        XCTAssertFalse(defaults.hasCompletedOnboarding)
    }

    func testLaunchAtLogin_defaultIsTrue() {
        let defaults = AppSettings.default
        XCTAssertTrue(defaults.launchAtLogin)
    }

    func testSettingsManager_completeOnboarding_method() {
        XCTAssertFalse(SettingsManager.shared.hasCompletedOnboarding)
        SettingsManager.shared.completeOnboarding()
        XCTAssertTrue(SettingsManager.shared.hasCompletedOnboarding)
    }

    func testSettingsManager_launchAtLogin_persistence() {
        let original = SettingsManager.shared.launchAtLogin
        SettingsManager.shared.launchAtLogin = !original
        XCTAssertEqual(SettingsManager.shared.launchAtLogin, !original)

        // Restore
        SettingsManager.shared.launchAtLogin = original
    }
}

// MARK: - Onboarding Stress Tests

final class OnboardingStressTests: XCTestCase {

    override func setUp() {
        super.setUp()
        #if DEBUG
        OnboardingManager.shared.reset()
        #endif
    }

    override func tearDown() {
        #if DEBUG
        OnboardingManager.shared.reset()
        #endif
        super.tearDown()
    }

    func testRapidNext_100Times_doesNotCrash() {
        let manager = OnboardingManager.shared

        for _ in 0..<100 {
            manager.next()
        }

        // After many next() calls, should have completed
        XCTAssertTrue(manager.isOnboardingComplete)
    }

    func testRapidPrevious_100Times_doesNotCrash() {
        let manager = OnboardingManager.shared
        manager.goToStep(.success)

        for _ in 0..<100 {
            manager.previous()
        }

        // Should be at welcome (can't go before welcome)
        XCTAssertEqual(manager.currentStep, .welcome)
    }

    func testRapidNextPrevious_alternating_doesNotCrash() {
        let manager = OnboardingManager.shared
        manager.goToStep(.howItWorks)

        for _ in 0..<50 {
            manager.next()
            manager.previous()
        }

        // Should end at howItWorks (next goes to permission, previous goes back)
        XCTAssertEqual(manager.currentStep, .howItWorks)
    }

    func testRapidGoToStep_allSteps_100Times_doesNotCrash() {
        let manager = OnboardingManager.shared

        for _ in 0..<100 {
            for step in OnboardingStep.allCases {
                manager.goToStep(step)
                XCTAssertEqual(manager.currentStep, step)
            }
        }
    }

    func testRapidReset_100Times_doesNotCrash() {
        let manager = OnboardingManager.shared

        for _ in 0..<100 {
            manager.goToStep(.success)
            manager.complete()
            #if DEBUG
            manager.reset()
            #endif
        }

        XCTAssertEqual(manager.currentStep, .welcome)
        XCTAssertFalse(manager.isOnboardingComplete)
    }

    func testMultipleComplete_doesNotCrash() {
        let manager = OnboardingManager.shared

        for _ in 0..<100 {
            manager.complete()
        }

        XCTAssertTrue(manager.isOnboardingComplete)
    }

    func testViewModelCreation_100Times_doesNotCrash() {
        for _ in 0..<100 {
            let vm = OnboardingViewModel()
            XCTAssertNotNil(vm)
            XCTAssertEqual(vm.progress, 0.0, accuracy: 0.001)
        }
    }

    func testViewModel_rapidUpdateLaunchAtLogin_doesNotCrash() {
        let vm = OnboardingViewModel()
        let original = vm.launchAtLogin

        for i in 0..<100 {
            vm.updateLaunchAtLogin(i % 2 == 0)
        }

        // Restore
        vm.updateLaunchAtLogin(original)
    }

    func testViewModel_rapidNext_doesNotCrash() {
        let vm = OnboardingViewModel()

        for _ in 0..<100 {
            vm.next()
        }

        // Should have completed
        XCTAssertTrue(OnboardingManager.shared.isOnboardingComplete)
    }

    func testViewModel_rapidPrevious_doesNotCrash() {
        let vm = OnboardingViewModel()
        OnboardingManager.shared.goToStep(.success)

        for _ in 0..<100 {
            vm.previous()
        }

        let expectation = expectation(description: "step syncs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(vm.currentStep, .welcome)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
