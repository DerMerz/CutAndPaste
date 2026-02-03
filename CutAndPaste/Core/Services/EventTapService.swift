import AppKit
import Carbon.HIToolbox
import Combine

final class EventTapService: ObservableObject {

    static let shared = EventTapService()

    @Published private(set) var isRunning: Bool = false

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private let cutStateManager: CutStateManager
    private let finderMonitor: FinderMonitorService
    private let settingsManager: SettingsManager

    var onCutPerformed: (() -> Void)?
    var onPastePerformed: (() -> Void)?

    private init(
        cutStateManager: CutStateManager = .shared,
        finderMonitor: FinderMonitorService = .shared,
        settingsManager: SettingsManager = .shared
    ) {
        self.cutStateManager = cutStateManager
        self.finderMonitor = finderMonitor
        self.settingsManager = settingsManager
    }

    deinit {
        stop()
    }

    // MARK: - Public Methods

    func start() {
        guard eventTap == nil else { return }
        guard AccessibilityService.shared.isAccessibilityEnabled else { return }

        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)

        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon = refcon else { return Unmanaged.passUnretained(event) }

            let service = Unmanaged<EventTapService>.fromOpaque(refcon).takeUnretainedValue()
            return service.handleEvent(proxy: proxy, type: type, event: event)
        }

        let refcon = Unmanaged.passUnretained(self).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: refcon
        )

        guard let eventTap = eventTap else {
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        if let runLoopSource = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: eventTap, enable: true)
        isRunning = true
    }

    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isRunning = false
    }

    func restart() {
        stop()
        start()
    }

    // MARK: - Private Methods

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }

        guard settingsManager.settings.isEnabled else {
            return Unmanaged.passUnretained(event)
        }

        guard finderMonitor.isFinderActive else {
            return Unmanaged.passUnretained(event)
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        // Command+X -> Simulate Copy and set Cut mode
        if keyCode == CGKeyCode.kVK_ANSI_X && flags.isOnlyCommand {
            simulateCopyAndActivateCutMode()
            onCutPerformed?()
            return nil // Consume the event
        }

        // Command+V with Cut mode active -> Simulate Option+Command+V (Move)
        if keyCode == CGKeyCode.kVK_ANSI_V && flags.isOnlyCommand && cutStateManager.cutState.isActive {
            simulateMoveAndDeactivateCutMode()
            onPastePerformed?()
            return nil // Consume the event
        }

        // Command+C -> Clear cut mode (user copied something else)
        if keyCode == CGKeyCode.kVK_ANSI_C && flags.isOnlyCommand {
            cutStateManager.deactivateCutMode()
        }

        return Unmanaged.passUnretained(event)
    }

    private func simulateCopyAndActivateCutMode() {
        // Simulate Cmd+C to copy files
        simulateKeyPress(keyCode: CGKeyCode.kVK_ANSI_C, flags: .maskCommand)

        // Small delay to ensure copy is complete before activating cut mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.cutStateManager.activateCutMode()
        }
    }

    private func simulateMoveAndDeactivateCutMode() {
        // Deactivate cut mode first to prevent re-triggering
        cutStateManager.deactivateCutMode()

        // Small delay to ensure state is updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { [weak self] in
            // Simulate Cmd+Option+V to move files (Finder's native move command)
            self?.simulateKeyPress(keyCode: CGKeyCode.kVK_ANSI_V, flags: [.maskCommand, .maskAlternate])
        }
    }

    private func simulateKeyPress(keyCode: CGKeyCode, flags: CGEventFlags) {
        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            return
        }

        keyDown.flags = flags
        keyUp.flags = flags

        keyDown.post(tap: .cghidEventTap)

        // Small delay between key down and key up for reliability
        usleep(10000) // 10ms

        keyUp.post(tap: .cghidEventTap)
    }
}
