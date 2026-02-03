import AppKit
import Combine

final class MenuBarViewModel: ObservableObject {

    @Published var isCutModeActive: Bool = false
    @Published var isEnabled: Bool
    @Published var isAccessibilityEnabled: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    private let cutStateManager: CutStateManager
    private let settingsManager: SettingsManager
    private let accessibilityService: AccessibilityService
    private let eventTapService: EventTapService
    private let ratingService: RatingService

    private var cancellables = Set<AnyCancellable>()

    init(
        cutStateManager: CutStateManager = .shared,
        settingsManager: SettingsManager = .shared,
        accessibilityService: AccessibilityService = .shared,
        eventTapService: EventTapService = .shared,
        ratingService: RatingService = .shared
    ) {
        self.cutStateManager = cutStateManager
        self.settingsManager = settingsManager
        self.accessibilityService = accessibilityService
        self.eventTapService = eventTapService
        self.ratingService = ratingService

        // Initialize with current value from SettingsManager to avoid visual toggle glitch
        self.isEnabled = settingsManager.settings.isEnabled

        setupBindings()
        setupEventTapCallbacks()
    }

    // MARK: - Public Methods

    var menuBarIcon: String {
        isCutModeActive ? Constants.MenuBar.iconCutActive : Constants.MenuBar.iconDefault
    }

    var statusText: String {
        if !isAccessibilityEnabled {
            return "Berechtigung erforderlich"
        }
        if !isEnabled {
            return "Deaktiviert"
        }
        if isCutModeActive {
            return "Ausschneiden aktiv"
        }
        return "Bereit"
    }

    var statusColor: NSColor {
        if !isAccessibilityEnabled {
            return .systemOrange
        }
        if !isEnabled {
            return .secondaryLabelColor
        }
        if isCutModeActive {
            return .systemGreen
        }
        return .labelColor
    }

    func toggleEnabled() {
        settingsManager.isEnabled.toggle()
    }

    func openSettings() {
        NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
    }

    func openAccessibilitySettings() {
        accessibilityService.openSystemPreferences()
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

    func clearCutMode() {
        cutStateManager.deactivateCutMode()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        cutStateManager.$cutState
            .map { $0.isActive }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCutModeActive)

        settingsManager.$settings
            .map { $0.isEnabled }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isEnabled)

        accessibilityService.$isAccessibilityEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAccessibilityEnabled)
    }

    private func setupEventTapCallbacks() {
        eventTapService.onCutPerformed = { [weak self] in
            guard let self = self, self.settingsManager.showVisualFeedback else { return }
            self.showToastMessage("Ausgeschnitten")
        }

        eventTapService.onPastePerformed = { [weak self] in
            guard let self = self, self.settingsManager.showVisualFeedback else { return }
            self.showToastMessage("Verschoben")
        }
    }

    private func showToastMessage(_ message: String) {
        DispatchQueue.main.async {
            self.toastMessage = message
            self.showToast = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showToast = false
            }
        }
    }
}
