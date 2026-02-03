import XCTest
@testable import CutAndPaste

final class RatingServiceTests: XCTestCase {

    var sut: RatingService!
    let testDefaults = UserDefaults(suiteName: "TestDefaults")!

    override func setUp() {
        super.setUp()
        sut = RatingService.shared
        // Reset state for testing
        #if DEBUG
        sut.resetState()
        #endif
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "TestDefaults")
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_skipCountIsZero() {
        XCTAssertEqual(sut.state.skipCount, 0)
    }

    func testInitialState_hasNotRated() {
        XCTAssertFalse(sut.state.hasRated)
    }

    func testInitialState_hasNotGivenFeedback() {
        XCTAssertFalse(sut.state.hasGivenFeedback)
    }

    func testInitialState_isNotDismissedPermanently() {
        XCTAssertFalse(sut.state.isDismissedPermanently)
    }

    // MARK: - Skip Tests

    func testHandleSkip_incrementsSkipCount() {
        // Given
        let initialCount = sut.state.skipCount

        // When
        sut.handleSkip()

        // Then
        XCTAssertEqual(sut.state.skipCount, initialCount + 1)
    }

    func testHandleSkip_updatesLastPromptDate() {
        // When
        sut.handleSkip()

        // Then
        XCTAssertNotNil(sut.state.lastPromptDate)
    }

    func testHandleSkip_afterMaxSkips_dismissesPermanently() {
        // Given - skip max times
        for _ in 0..<Constants.Rating.maxSkipCount {
            sut.handleSkip()
        }

        // Then
        XCTAssertTrue(sut.state.isDismissedPermanently)
    }

    func testHandleSkip_afterMaxSkips_shouldNeverShowAgain() {
        // Given - skip max times
        for _ in 0..<Constants.Rating.maxSkipCount {
            sut.handleSkip()
        }

        // Then
        XCTAssertTrue(sut.state.shouldNeverShowAgain)
    }

    func testHandleSkip_hidesPrompt() {
        // Given
        #if DEBUG
        sut.triggerPromptForDebug()
        #endif
        XCTAssertTrue(sut.shouldShowPrompt)

        // When
        sut.handleSkip()

        // Then
        XCTAssertFalse(sut.shouldShowPrompt)
    }

    // MARK: - Positive Response Tests

    func testHandlePositiveResponse_setsHasRated() {
        // When
        sut.handlePositiveResponse()

        // Then
        XCTAssertTrue(sut.state.hasRated)
    }

    func testHandlePositiveResponse_dismissesPermanently() {
        // When
        sut.handlePositiveResponse()

        // Then
        XCTAssertTrue(sut.state.isDismissedPermanently)
    }

    func testHandlePositiveResponse_hidesPrompt() {
        // Given
        #if DEBUG
        sut.triggerPromptForDebug()
        #endif

        // When
        sut.handlePositiveResponse()

        // Then
        XCTAssertFalse(sut.shouldShowPrompt)
    }

    // MARK: - Negative Response Tests

    func testHandleNegativeResponse_setsHasGivenFeedback() {
        // When
        sut.handleNegativeResponse()

        // Then
        XCTAssertTrue(sut.state.hasGivenFeedback)
    }

    func testHandleNegativeResponse_dismissesPermanently() {
        // When
        sut.handleNegativeResponse()

        // Then
        XCTAssertTrue(sut.state.isDismissedPermanently)
    }

    func testHandleNegativeResponse_hidesPrompt() {
        // Given
        #if DEBUG
        sut.triggerPromptForDebug()
        #endif

        // When
        sut.handleNegativeResponse()

        // Then
        XCTAssertFalse(sut.shouldShowPrompt)
    }

    // MARK: - Usage Recording Tests

    func testRecordAppUsage_incrementsUsageDays_onFirstUse() {
        // Given
        #if DEBUG
        sut.resetState()
        #endif
        XCTAssertEqual(sut.state.usageDaysCount, 0)

        // When
        sut.recordAppUsage()

        // Then
        XCTAssertEqual(sut.state.usageDaysCount, 1)
    }

    func testRecordAppUsage_setsFirstLaunchDate() {
        // Given
        #if DEBUG
        sut.resetState()
        #endif

        // When
        sut.recordAppUsage()

        // Then
        XCTAssertNotNil(sut.state.firstLaunchDate)
    }

    func testRecordAppUsage_updatesLastUsageDate() {
        // When
        sut.recordAppUsage()

        // Then
        XCTAssertNotNil(sut.state.lastUsageDate)
    }

    // MARK: - shouldNeverShowAgain Tests

    func testShouldNeverShowAgain_afterRating_isTrue() {
        // When
        sut.handlePositiveResponse()

        // Then
        XCTAssertTrue(sut.state.shouldNeverShowAgain)
    }

    func testShouldNeverShowAgain_afterFeedback_isTrue() {
        // When
        sut.handleNegativeResponse()

        // Then
        XCTAssertTrue(sut.state.shouldNeverShowAgain)
    }

    func testShouldNeverShowAgain_afterMaxSkips_isTrue() {
        // When
        for _ in 0..<Constants.Rating.maxSkipCount {
            sut.handleSkip()
        }

        // Then
        XCTAssertTrue(sut.state.shouldNeverShowAgain)
    }

    func testShouldNeverShowAgain_initially_isFalse() {
        // Given
        #if DEBUG
        sut.resetState()
        #endif

        // Then
        XCTAssertFalse(sut.state.shouldNeverShowAgain)
    }

    // MARK: - Debug Tests

    #if DEBUG
    func testTriggerPromptForDebug_showsPrompt() {
        // When
        sut.triggerPromptForDebug()

        // Then
        XCTAssertTrue(sut.shouldShowPrompt)
    }

    func testResetState_resetsAllValues() {
        // Given
        sut.handleSkip()
        sut.handleSkip()

        // When
        sut.resetState()

        // Then
        XCTAssertEqual(sut.state.skipCount, 0)
        XCTAssertFalse(sut.state.hasRated)
        XCTAssertFalse(sut.state.hasGivenFeedback)
        XCTAssertFalse(sut.state.isDismissedPermanently)
        XCTAssertFalse(sut.shouldShowPrompt)
    }
    #endif

    // MARK: - Singleton Test

    func testSharedInstance_returnsSameInstance() {
        let instance1 = RatingService.shared
        let instance2 = RatingService.shared
        XCTAssertTrue(instance1 === instance2)
    }
}

// MARK: - RatingState Tests

final class RatingStateTests: XCTestCase {

    func testInitial_allValuesAreDefault() {
        let state = RatingState.initial

        XCTAssertEqual(state.skipCount, 0)
        XCTAssertNil(state.lastPromptDate)
        XCTAssertFalse(state.hasRated)
        XCTAssertFalse(state.hasGivenFeedback)
        XCTAssertFalse(state.isDismissedPermanently)
        XCTAssertEqual(state.usageDaysCount, 0)
        XCTAssertNil(state.lastUsageDate)
        XCTAssertNil(state.firstLaunchDate)
    }

    func testRecordSkip_incrementsCount() {
        var state = RatingState.initial
        state.recordSkip()
        XCTAssertEqual(state.skipCount, 1)
    }

    func testRecordSkip_atMaxCount_dismissesPermanently() {
        var state = RatingState.initial

        for _ in 0..<Constants.Rating.maxSkipCount {
            state.recordSkip()
        }

        XCTAssertTrue(state.isDismissedPermanently)
    }

    func testRecordRating_setsFlags() {
        var state = RatingState.initial
        state.recordRating()

        XCTAssertTrue(state.hasRated)
        XCTAssertTrue(state.isDismissedPermanently)
    }

    func testRecordFeedback_setsFlags() {
        var state = RatingState.initial
        state.recordFeedback()

        XCTAssertTrue(state.hasGivenFeedback)
        XCTAssertTrue(state.isDismissedPermanently)
    }

    func testRecordUsage_firstTime_setsCountToOne() {
        var state = RatingState.initial
        state.recordUsage()

        XCTAssertEqual(state.usageDaysCount, 1)
    }

    func testRecordUsage_sameDay_doesNotIncrement() {
        var state = RatingState.initial
        state.recordUsage()

        let initialCount = state.usageDaysCount
        state.recordUsage()

        XCTAssertEqual(state.usageDaysCount, initialCount)
    }

    func testCanShowPrompt_whenDismissedPermanently_isFalse() {
        var state = RatingState.initial
        state.isDismissedPermanently = true

        XCTAssertFalse(state.canShowPrompt)
    }

    func testCanShowPrompt_whenHasRated_isFalse() {
        var state = RatingState.initial
        state.hasRated = true

        XCTAssertFalse(state.canShowPrompt)
    }

    func testCanShowPrompt_whenHasGivenFeedback_isFalse() {
        var state = RatingState.initial
        state.hasGivenFeedback = true

        XCTAssertFalse(state.canShowPrompt)
    }

    func testCanShowPrompt_whenMaxSkipsReached_isFalse() {
        var state = RatingState.initial
        state.skipCount = Constants.Rating.maxSkipCount

        XCTAssertFalse(state.canShowPrompt)
    }
}
