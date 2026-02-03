import AppKit
import Combine

final class OnboardingViewModel: ObservableObject {

    @Published var currentStep: OnboardingStep = .welcome
    @Published var isPermissionGranted: Bool = false
    @Published var isCheckingPermission: Bool = false
    @Published var launchAtLogin: Bool

    private let onboardingManager: OnboardingManager
    private let accessibilityService: AccessibilityService
    private let settingsManager: SettingsManager

    private var cancellables = Set<AnyCancellable>()

    init(
        onboardingManager: OnboardingManager = .shared,
        accessibilityService: AccessibilityService = .shared,
        settingsManager: SettingsManager = .shared
    ) {
        self.onboardingManager = onboardingManager
        self.accessibilityService = accessibilityService
        self.settingsManager = settingsManager

        // Initialize with current value from settings
        self.launchAtLogin = settingsManager.settings.launchAtLogin

        setupBindings()
    }

    // MARK: - Public Properties

    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }

    var canGoBack: Bool {
        !currentStep.isFirst
    }

    var canGoNext: Bool {
        switch currentStep {
        case .permission:
            return isPermissionGranted
        default:
            return true
        }
    }

    var nextButtonTitle: String {
        switch currentStep {
        case .welcome:
            return "onboarding.button.next".localized
        case .howItWorks:
            return "onboarding.button.next".localized
        case .permission:
            return isPermissionGranted ? "onboarding.button.next".localized : "onboarding.button.grant_permission".localized
        case .success:
            return "onboarding.button.get_started".localized
        }
    }

    // MARK: - Public Methods

    func next() {
        if currentStep == .permission && !isPermissionGranted {
            requestPermission()
            return
        }

        onboardingManager.next()
    }

    func previous() {
        onboardingManager.previous()
    }

    func complete() {
        onboardingManager.complete()
    }

    func updateLaunchAtLogin(_ value: Bool) {
        launchAtLogin = value
        settingsManager.launchAtLogin = value
    }

    func requestPermission() {
        isCheckingPermission = true

        // This will show the system prompt to add the app to accessibility
        accessibilityService.requestPermission()

        // Also open system preferences
        onboardingManager.openSystemPreferences()

        // Permission will be detected by the observer
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isCheckingPermission = false
        }
    }

    // MARK: - Private Methods

    private func setupBindings() {
        onboardingManager.$currentStep
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentStep)

        accessibilityService.$isAccessibilityEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isEnabled: Bool) in
                guard let self = self else { return }
                self.isPermissionGranted = isEnabled

                // Auto-advance to success when permission is granted on permission screen
                if isEnabled && self.currentStep == OnboardingStep.permission {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.onboardingManager.goToStep(.success)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
