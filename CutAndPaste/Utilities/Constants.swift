import Foundation

enum Constants {

    // MARK: - App Info

    enum App {
        static let name = "Cut & Place"
        static let bundleIdentifier = "de.merzkevin.cutandmove"
        static let supportEmail = "MerzKevin@me.com"
        static let appStoreId = "" // Will be set after App Store submission

        static var version: String {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        }

        static var build: String {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        }

        static var fullVersion: String {
            "\(version) (\(build))"
        }
    }

    // MARK: - UserDefaults Keys

    enum UserDefaultsKeys {
        static let isEnabled = "isEnabled"
        static let launchAtLogin = "launchAtLogin"
        static let showVisualFeedback = "showVisualFeedback"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let firstLaunchDate = "firstLaunchDate"

        // Rating
        static let ratingSkipCount = "ratingSkipCount"
        static let lastRatingPromptDate = "lastRatingPromptDate"
        static let hasRatedApp = "hasRatedApp"
        static let hasGivenFeedback = "hasGivenFeedback"
        static let ratingDismissedPermanently = "ratingDismissedPermanently"
        static let usageDaysCount = "usageDaysCount"
        static let lastUsageDate = "lastUsageDate"
    }

    // MARK: - Rating Configuration

    enum Rating {
        static let maxSkipCount = 3
        static let daysBeforeFirstPrompt = 3
        static let daysBetweenPrompts = 2
        static let requiredUsageDays = 3
    }

    // MARK: - Finder

    enum Finder {
        static let bundleIdentifier = "com.apple.finder"
    }

    // MARK: - URLs

    enum URLs {
        static let accessibilityPreferences = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

        static var appStoreReview: String {
            "https://apps.apple.com/app/id\(App.appStoreId)?action=write-review"
        }

        static var appStorePage: String {
            "https://apps.apple.com/app/id\(App.appStoreId)"
        }
    }

    // MARK: - Notifications

    enum Notifications {
        static let cutModeDidChange = Notification.Name("cutModeDidChange")
        static let accessibilityPermissionDidChange = Notification.Name("accessibilityPermissionDidChange")
        static let settingsDidChange = Notification.Name("settingsDidChange")
    }

    // MARK: - Menu Bar

    enum MenuBar {
        static let iconDefault = "scissors"
        static let iconCutActive = "scissors.badge.ellipsis"
    }

    // MARK: - Device Info

    enum Device {
        static var macOSVersion: String {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        }

        static var deviceModel: String {
            var size = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var model = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.model", &model, &size, nil, 0)
            return String(cString: model)
        }

        static var systemInfo: String {
            """
            macOS Version: \(macOSVersion)
            Device: \(deviceModel)
            App Version: \(App.fullVersion)
            """
        }
    }
}
