import Foundation
import Combine

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case howItWorks = 1
    case permission = 2
    case success = 3

    var title: String {
        switch self {
        case .welcome:
            return "onboarding.step.welcome".localized
        case .howItWorks:
            return "onboarding.step.howitworks".localized
        case .permission:
            return "onboarding.step.permission".localized
        case .success:
            return "onboarding.step.success".localized
        }
    }

    var isFirst: Bool {
        self == .welcome
    }

    var isLast: Bool {
        self == .success
    }

    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var previous: OnboardingStep? {
        OnboardingStep(rawValue: rawValue - 1)
    }
}

final class OnboardingManager: ObservableObject {

    static let shared = OnboardingManager()

    @Published var currentStep: OnboardingStep = .welcome
    @Published var isOnboardingComplete: Bool = false

    private let settingsManager: SettingsManager
    private let accessibilityService: AccessibilityService
    private var cancellables = Set<AnyCancellable>()

    init(
        settingsManager: SettingsManager = .shared,
        accessibilityService: AccessibilityService = .shared
    ) {
        self.settingsManager = settingsManager
        self.accessibilityService = accessibilityService
        self.isOnboardingComplete = settingsManager.hasCompletedOnboarding

        setupObservers()
    }

    // MARK: - Public Methods

    var needsOnboarding: Bool {
        !settingsManager.hasCompletedOnboarding
    }

    func start() {
        currentStep = .welcome
    }

    func next() {
        guard let nextStep = currentStep.next else {
            complete()
            return
        }
        currentStep = nextStep
    }

    func previous() {
        guard let previousStep = currentStep.previous else { return }
        currentStep = previousStep
    }

    func goToStep(_ step: OnboardingStep) {
        currentStep = step
    }

    func complete() {
        settingsManager.completeOnboarding()
        isOnboardingComplete = true
    }

    func requestPermission() {
        accessibilityService.requestPermission()
    }

    func openSystemPreferences() {
        accessibilityService.openSystemPreferences()
    }

    var isPermissionGranted: Bool {
        accessibilityService.isAccessibilityEnabled
    }

    // MARK: - Private Methods

    private func setupObservers() {
        accessibilityService.$isAccessibilityEnabled
            .dropFirst() // Ignore initial value
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isEnabled: Bool) in
                guard let self = self else { return }

                if isEnabled && self.currentStep == .permission {
                    self.currentStep = .success
                }
            }
            .store(in: &cancellables)
    }

    #if DEBUG
    func reset() {
        currentStep = .welcome
        isOnboardingComplete = false
    }
    #endif
}
