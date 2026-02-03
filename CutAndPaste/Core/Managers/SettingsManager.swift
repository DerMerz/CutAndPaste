import Foundation
import Combine
import ServiceManagement

final class SettingsManager: ObservableObject {

    static let shared = SettingsManager()

    @Published var settings: AppSettings {
        didSet {
            saveSettings()
            NotificationCenter.default.post(name: Constants.Notifications.settingsDidChange, object: nil)
        }
    }

    private let defaults = UserDefaults.standard

    private init() {
        let loadedSettings = SettingsManager.loadSettings(defaults: defaults)
        settings = loadedSettings.settings

        // Ensure settings are persisted on first launch
        if loadedSettings.isFirstLaunch {
            saveSettings()
        }
    }

    // MARK: - Public Methods

    var isEnabled: Bool {
        get { settings.isEnabled }
        set { settings.isEnabled = newValue }
    }

    var launchAtLogin: Bool {
        get { settings.launchAtLogin }
        set {
            settings.launchAtLogin = newValue
            updateLaunchAtLogin(newValue)
        }
    }

    var showVisualFeedback: Bool {
        get { settings.showVisualFeedback }
        set { settings.showVisualFeedback = newValue }
    }

    var hasCompletedOnboarding: Bool {
        get { settings.hasCompletedOnboarding }
        set { settings.hasCompletedOnboarding = newValue }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    // MARK: - Private Methods

    private func saveSettings() {
        defaults.set(settings.isEnabled, forKey: Constants.UserDefaultsKeys.isEnabled)
        defaults.set(settings.launchAtLogin, forKey: Constants.UserDefaultsKeys.launchAtLogin)
        defaults.set(settings.showVisualFeedback, forKey: Constants.UserDefaultsKeys.showVisualFeedback)
        defaults.set(settings.hasCompletedOnboarding, forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
    }

    private static func loadSettings(defaults: UserDefaults) -> (settings: AppSettings, isFirstLaunch: Bool) {
        // Check if this is first launch
        if defaults.object(forKey: Constants.UserDefaultsKeys.isEnabled) == nil {
            return (.default, true)
        }

        let settings = AppSettings(
            isEnabled: defaults.bool(forKey: Constants.UserDefaultsKeys.isEnabled),
            launchAtLogin: defaults.bool(forKey: Constants.UserDefaultsKeys.launchAtLogin),
            showVisualFeedback: defaults.bool(forKey: Constants.UserDefaultsKeys.showVisualFeedback),
            hasCompletedOnboarding: defaults.bool(forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
        )
        return (settings, false)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Handle error silently - user can retry
            }
        } else {
            // For macOS 11-12, use legacy approach
            let launcherBundleId = "\(Constants.App.bundleIdentifier).LaunchHelper"
            SMLoginItemSetEnabled(launcherBundleId as CFString, enabled)
        }
    }
}
