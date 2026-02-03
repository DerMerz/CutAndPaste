import Foundation

struct RatingState: Codable, Equatable {

    var skipCount: Int
    var lastPromptDate: Date?
    var hasRated: Bool
    var hasGivenFeedback: Bool
    var isDismissedPermanently: Bool
    var usageDaysCount: Int
    var lastUsageDate: Date?
    var firstLaunchDate: Date?

    static let initial = RatingState(
        skipCount: 0,
        lastPromptDate: nil,
        hasRated: false,
        hasGivenFeedback: false,
        isDismissedPermanently: false,
        usageDaysCount: 0,
        lastUsageDate: nil,
        firstLaunchDate: nil
    )

    var canShowPrompt: Bool {
        guard !isDismissedPermanently else { return false }
        guard !hasRated && !hasGivenFeedback else { return false }
        guard skipCount < Constants.Rating.maxSkipCount else { return false }
        guard usageDaysCount >= Constants.Rating.requiredUsageDays else { return false }

        if let lastPrompt = lastPromptDate {
            let daysSinceLastPrompt = Date().daysSince(lastPrompt)
            return daysSinceLastPrompt >= Constants.Rating.daysBetweenPrompts
        }

        if let firstLaunch = firstLaunchDate {
            let daysSinceFirstLaunch = Date().daysSince(firstLaunch)
            return daysSinceFirstLaunch >= Constants.Rating.daysBeforeFirstPrompt
        }

        return false
    }

    var shouldNeverShowAgain: Bool {
        isDismissedPermanently || skipCount >= Constants.Rating.maxSkipCount || hasRated || hasGivenFeedback
    }

    mutating func recordSkip() {
        skipCount += 1
        lastPromptDate = Date()

        if skipCount >= Constants.Rating.maxSkipCount {
            isDismissedPermanently = true
        }
    }

    mutating func recordRating() {
        hasRated = true
        isDismissedPermanently = true
    }

    mutating func recordFeedback() {
        hasGivenFeedback = true
        isDismissedPermanently = true
    }

    mutating func recordUsage() {
        let today = Date()

        if let lastUsage = lastUsageDate, !today.isOnSameDay(as: lastUsage) {
            usageDaysCount += 1
        } else if lastUsageDate == nil {
            usageDaysCount = 1
        }

        lastUsageDate = today

        if firstLaunchDate == nil {
            firstLaunchDate = today
        }
    }
}
