import Foundation

struct AppSettings: Codable, Equatable {

    var isEnabled: Bool
    var launchAtLogin: Bool
    var showVisualFeedback: Bool
    var hasCompletedOnboarding: Bool

    static let `default` = AppSettings(
        isEnabled: true,
        launchAtLogin: true,
        showVisualFeedback: true,
        hasCompletedOnboarding: false
    )
}
