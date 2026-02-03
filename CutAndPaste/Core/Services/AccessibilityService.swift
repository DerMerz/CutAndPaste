import AppKit
import Combine

final class AccessibilityService: ObservableObject {

    static let shared = AccessibilityService()

    @Published private(set) var isAccessibilityEnabled: Bool = false

    private var checkTimer: Timer?

    private init() {
        checkPermission()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    func checkPermission() {
        let newValue = AXIsProcessTrusted()
        DispatchQueue.main.async {
            if self.isAccessibilityEnabled != newValue {
                self.isAccessibilityEnabled = newValue
            }
        }
    }

    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        checkPermission()
    }

    func openSystemPreferences() {
        NSApplication.openAccessibilityPreferences()
    }

    // MARK: - Private Methods

    private func startMonitoring() {
        // Make sure timer runs on main run loop
        DispatchQueue.main.async {
            self.checkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.checkPermission()
            }
            // Ensure timer fires during UI interactions
            if let timer = self.checkTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }

    private func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
    }
}
