import XCTest
@testable import CutAndPaste

final class CutStateManagerTests: XCTestCase {

    var sut: CutStateManager!

    override func setUp() {
        super.setUp()
        sut = CutStateManager.shared
        sut.deactivateCutMode()
    }

    override func tearDown() {
        sut.deactivateCutMode()
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_isInactive() {
        // Given
        sut.deactivateCutMode()

        // Then
        XCTAssertFalse(sut.cutState.isActive)
    }

    // MARK: - Activate Tests

    func testActivateCutMode_setsStateToActive() {
        // When
        sut.activateCutMode()

        // Then
        XCTAssertTrue(sut.cutState.isActive)
    }

    func testActivateCutMode_createsOperation() {
        // When
        sut.activateCutMode()

        // Then
        XCTAssertNotNil(sut.cutState.operation)
    }

    func testActivateCutMode_withFileCount_storesFileCount() {
        // When
        sut.activateCutMode(fileCount: 5)

        // Then
        XCTAssertEqual(sut.cutState.operation?.fileCount, 5)
    }

    func testActivateCutMode_setsTimestamp() {
        // Given
        let beforeActivation = Date()

        // When
        sut.activateCutMode()

        // Then
        let afterActivation = Date()
        if let timestamp = sut.cutState.operation?.timestamp {
            XCTAssertGreaterThanOrEqual(timestamp, beforeActivation)
            XCTAssertLessThanOrEqual(timestamp, afterActivation)
        } else {
            XCTFail("Timestamp should be set")
        }
    }

    // MARK: - Deactivate Tests

    func testDeactivateCutMode_setsStateToInactive() {
        // Given
        sut.activateCutMode()

        // When
        sut.deactivateCutMode()

        // Then
        XCTAssertFalse(sut.cutState.isActive)
    }

    func testDeactivateCutMode_clearsOperation() {
        // Given
        sut.activateCutMode()

        // When
        sut.deactivateCutMode()

        // Then
        XCTAssertNil(sut.cutState.operation)
    }

    func testDeactivateCutMode_whenAlreadyInactive_remainsInactive() {
        // Given
        sut.deactivateCutMode()

        // When
        sut.deactivateCutMode()

        // Then
        XCTAssertFalse(sut.cutState.isActive)
    }

    // MARK: - Toggle Tests

    func testToggle_fromInactive_becomesActive() {
        // Given
        sut.deactivateCutMode()

        // When
        sut.toggle()

        // Then
        XCTAssertTrue(sut.cutState.isActive)
    }

    func testToggle_fromActive_becomesInactive() {
        // Given
        sut.activateCutMode()

        // When
        sut.toggle()

        // Then
        XCTAssertFalse(sut.cutState.isActive)
    }

    // MARK: - Notification Tests

    func testActivateCutMode_postsNotification() {
        // Given
        let expectation = expectation(forNotification: Constants.Notifications.cutModeDidChange, object: nil)

        // When
        sut.activateCutMode()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testDeactivateCutMode_postsNotification() {
        // Given
        sut.activateCutMode()
        let expectation = expectation(forNotification: Constants.Notifications.cutModeDidChange, object: nil)

        // When
        sut.deactivateCutMode()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Singleton Test

    func testSharedInstance_returnsSameInstance() {
        let instance1 = CutStateManager.shared
        let instance2 = CutStateManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
}

// MARK: - CutOperation Tests

final class CutOperationTests: XCTestCase {

    func testIsRecent_whenJustCreated_returnsTrue() {
        // Given
        let operation = CutOperation()

        // Then
        XCTAssertTrue(operation.isRecent)
    }

    func testEquality() {
        // Given
        let timestamp = Date()
        let operation1 = CutOperation(timestamp: timestamp, fileCount: 3)
        let operation2 = CutOperation(timestamp: timestamp, fileCount: 3)

        // Then
        XCTAssertEqual(operation1, operation2)
    }

    func testInequality_differentFileCount() {
        // Given
        let timestamp = Date()
        let operation1 = CutOperation(timestamp: timestamp, fileCount: 3)
        let operation2 = CutOperation(timestamp: timestamp, fileCount: 5)

        // Then
        XCTAssertNotEqual(operation1, operation2)
    }
}

// MARK: - CutState Tests

final class CutStateTests: XCTestCase {

    func testInactive_isActiveFalse() {
        let state = CutState.inactive
        XCTAssertFalse(state.isActive)
    }

    func testActive_isActiveTrue() {
        let operation = CutOperation()
        let state = CutState.active(operation)
        XCTAssertTrue(state.isActive)
    }

    func testInactive_operationIsNil() {
        let state = CutState.inactive
        XCTAssertNil(state.operation)
    }

    func testActive_operationIsNotNil() {
        let operation = CutOperation()
        let state = CutState.active(operation)
        XCTAssertNotNil(state.operation)
    }
}
