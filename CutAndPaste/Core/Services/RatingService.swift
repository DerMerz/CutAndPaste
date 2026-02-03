import AppKit
import Combine
import StoreKit

final class RatingService: ObservableObject {

    static let shared = RatingService()

    @Published var state: RatingState
    @Published var shouldShowPrompt: Bool = false

    private let defaults = UserDefaults.standard

    private init() {
        state = RatingService.loadState()
    }

    // MARK: - Public Methods

    func recordAppUsage() {
        state.recordUsage()
        saveState()
    }

    func checkAndShowPromptIfNeeded() {
        guard state.canShowPrompt else { return }
        shouldShowPrompt = true
    }

    func handlePositiveResponse() {
        state.recordRating()
        saveState()
        shouldShowPrompt = false
        requestAppStoreReview()
    }

    func handleNegativeResponse() {
        state.recordFeedback()
        saveState()
        shouldShowPrompt = false
        openFeedbackEmail()
    }

    func handleSkip() {
        state.recordSkip()
        saveState()
        shouldShowPrompt = false
    }

    #if DEBUG
    func triggerPromptForDebug() {
        shouldShowPrompt = true
    }

    func resetState() {
        state = .initial
        saveState()
        shouldShowPrompt = false
    }
    #endif

    // MARK: - Debug Info

    var debugInfo: String {
        """
        Skip Count: \(state.skipCount) / \(Constants.Rating.maxSkipCount)
        Usage Days: \(state.usageDaysCount) / \(Constants.Rating.requiredUsageDays)
        Has Rated: \(state.hasRated)
        Has Given Feedback: \(state.hasGivenFeedback)
        Is Dismissed Permanently: \(state.isDismissedPermanently)
        Can Show Prompt: \(state.canShowPrompt)
        First Launch: \(state.firstLaunchDate?.description ?? "nil")
        Last Prompt: \(state.lastPromptDate?.description ?? "nil")
        Last Usage: \(state.lastUsageDate?.description ?? "nil")
        """
    }

    // MARK: - Private Methods

    private func requestAppStoreReview() {
        // SKStoreReviewController.requestReview() works on macOS 10.14+
        SKStoreReviewController.requestReview()
    }

    private func openFeedbackEmail() {
        NSApplication.composeFeedbackEmail()
    }

    private func saveState() {
        defaults.set(state.skipCount, forKey: Constants.UserDefaultsKeys.ratingSkipCount)
        defaults.setDate(state.lastPromptDate, forKey: Constants.UserDefaultsKeys.lastRatingPromptDate)
        defaults.set(state.hasRated, forKey: Constants.UserDefaultsKeys.hasRatedApp)
        defaults.set(state.hasGivenFeedback, forKey: Constants.UserDefaultsKeys.hasGivenFeedback)
        defaults.set(state.isDismissedPermanently, forKey: Constants.UserDefaultsKeys.ratingDismissedPermanently)
        defaults.set(state.usageDaysCount, forKey: Constants.UserDefaultsKeys.usageDaysCount)
        defaults.setDate(state.lastUsageDate, forKey: Constants.UserDefaultsKeys.lastUsageDate)
        defaults.setDate(state.firstLaunchDate, forKey: Constants.UserDefaultsKeys.firstLaunchDate)
    }

    private static func loadState() -> RatingState {
        let defaults = UserDefaults.standard

        return RatingState(
            skipCount: defaults.integer(forKey: Constants.UserDefaultsKeys.ratingSkipCount),
            lastPromptDate: defaults.date(forKey: Constants.UserDefaultsKeys.lastRatingPromptDate),
            hasRated: defaults.bool(forKey: Constants.UserDefaultsKeys.hasRatedApp),
            hasGivenFeedback: defaults.bool(forKey: Constants.UserDefaultsKeys.hasGivenFeedback),
            isDismissedPermanently: defaults.bool(forKey: Constants.UserDefaultsKeys.ratingDismissedPermanently),
            usageDaysCount: defaults.integer(forKey: Constants.UserDefaultsKeys.usageDaysCount),
            lastUsageDate: defaults.date(forKey: Constants.UserDefaultsKeys.lastUsageDate),
            firstLaunchDate: defaults.date(forKey: Constants.UserDefaultsKeys.firstLaunchDate)
        )
    }
}
