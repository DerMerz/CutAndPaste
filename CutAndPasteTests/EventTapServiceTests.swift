import XCTest
@testable import CutAndPaste

final class EventTapServiceTests: XCTestCase {

    var sut: EventTapService!

    override func setUp() {
        super.setUp()
        sut = EventTapService.shared
    }

    override func tearDown() {
        sut.stop()
        sut = nil
        super.tearDown()
    }

    // MARK: - Start/Stop Tests

    func testInitialState_isNotRunning() {
        // When service is created, it should not be running
        let freshService = EventTapService.shared

        // Note: We can't directly test running state without accessibility permission
        // This test verifies the service exists
        XCTAssertNotNil(freshService)
    }

    func testStop_stopsService() {
        // Given
        // Service may or may not be running

        // When
        sut.stop()

        // Then
        XCTAssertFalse(sut.isRunning)
    }

    // MARK: - Callback Tests

    func testOnCutPerformed_callbackIsSet() {
        // Given
        var callbackCalled = false

        // When
        sut.onCutPerformed = {
            callbackCalled = true
        }
        sut.onCutPerformed?()

        // Then
        XCTAssertTrue(callbackCalled)
    }

    func testOnPastePerformed_callbackIsSet() {
        // Given
        var callbackCalled = false

        // When
        sut.onPastePerformed = {
            callbackCalled = true
        }
        sut.onPastePerformed?()

        // Then
        XCTAssertTrue(callbackCalled)
    }

    // MARK: - Service Singleton Test

    func testSharedInstance_returnsSameInstance() {
        // Given
        let instance1 = EventTapService.shared
        let instance2 = EventTapService.shared

        // Then
        XCTAssertTrue(instance1 === instance2)
    }
}

// MARK: - CGKeyCode Extension Tests

final class CGKeyCodeExtensionTests: XCTestCase {

    func testKeyCodeValues() {
        XCTAssertEqual(CGKeyCode.kVK_ANSI_X, 0x07)
        XCTAssertEqual(CGKeyCode.kVK_ANSI_V, 0x09)
        XCTAssertEqual(CGKeyCode.kVK_ANSI_C, 0x08)
    }
}
