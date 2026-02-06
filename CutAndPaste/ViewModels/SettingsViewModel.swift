import AppKit
import Combine

final class SettingsViewModel: ObservableObject {

    @Published var isEnabled: Bool
    @Published var launchAtLogin: Bool
    @Published var showVisualFeedback: Bool
    @Published var isAccessibilityEnabled: Bool = false

    private let settingsManager: SettingsManager
    private let accessibilityService: AccessibilityService
    private let ratingService: RatingService

    private var cancellables = Set<AnyCancellable>()

    init(
        settingsManager: SettingsManager = .shared,
        accessibilityService: AccessibilityService = .shared,
        ratingService: RatingService = .shared
    ) {
        self.settingsManager = settingsManager
        self.accessibilityService = accessibilityService
        self.ratingService = ratingService

        // Initialize with current values from SettingsManager to avoid visual toggle glitches
        self.isEnabled = settingsManager.settings.isEnabled
        self.launchAtLogin = settingsManager.settings.launchAtLogin
        self.showVisualFeedback = settingsManager.settings.showVisualFeedback

        setupBindings()
    }

    // MARK: - Public Methods

    var appVersion: String {
        Constants.App.fullVersion
    }

    var supportEmail: String {
        Constants.App.supportEmail
    }

    func updateIsEnabled(_ value: Bool) {
        settingsManager.isEnabled = value
    }

    func updateLaunchAtLogin(_ value: Bool) {
        settingsManager.launchAtLogin = value
    }

    func updateShowVisualFeedback(_ value: Bool) {
        settingsManager.showVisualFeedback = value
    }

    func openAccessibilityPreferences() {
        accessibilityService.openSystemPreferences()
    }

    func sendFeedback() {
        NSApplication.composeFeedbackEmail()
    }

    func openAppStore() {
        ratingService.showPromptFromUser()
    }

    // MARK: - Debug Methods

    #if DEBUG
    var ratingDebugInfo: String {
        ratingService.debugInfo
    }

    func triggerRatingPrompt() {
        ratingService.triggerPromptForDebug()
    }

    func resetRatingState() {
        ratingService.resetState()
    }

    var cutStateDebugInfo: String {
        let cutState = CutStateManager.shared.cutState
        return """
        Cut Mode Active: \(cutState.isActive)
        Timestamp: \(cutState.operation?.timestamp.description ?? "N/A")
        """
    }
    #endif

    // MARK: - Private Methods

    private func setupBindings() {
        settingsManager.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                self?.isEnabled = settings.isEnabled
                self?.launchAtLogin = settings.launchAtLogin
                self?.showVisualFeedback = settings.showVisualFeedback
            }
            .store(in: &cancellables)

        accessibilityService.$isAccessibilityEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAccessibilityEnabled)
    }
}
