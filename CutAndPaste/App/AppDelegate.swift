import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var settingsWindow: NSWindow?
    private var onboardingWindow: NSWindow?

    private var cancellables = Set<AnyCancellable>()

    // Services
    private let accessibilityService = AccessibilityService.shared
    private let finderMonitor = FinderMonitorService.shared
    private let eventTapService = EventTapService.shared
    private let settingsManager = SettingsManager.shared
    private let onboardingManager = OnboardingManager.shared
    private let ratingService = RatingService.shared
    private let cutStateManager = CutStateManager.shared

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupBindings()

        // Check if onboarding is needed
        if onboardingManager.needsOnboarding {
            showOnboarding()
        } else {
            startEventTap()
        }

        // Record app usage for rating
        ratingService.recordAppUsage()

        // Setup toast callbacks
        setupToastCallbacks()
    }

    func applicationWillTerminate(_ notification: Notification) {
        eventTapService.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // MARK: - Menu Bar Setup

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: Constants.MenuBar.iconDefault, accessibilityDescription: "Cut & Paste")
            button.action = #selector(togglePopover)
            button.target = self
        }

        setupPopover()
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(ratingService)
        )
    }

    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Check if we should show rating prompt
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.ratingService.checkAndShowPromptIfNeeded()
            }
        }
    }

    // MARK: - Settings

    @objc func openSettings() {
        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.title = "Cut & Paste Einstellungen"
            settingsWindow?.center()
            settingsWindow?.contentView = NSHostingView(rootView: SettingsWindowView())
            settingsWindow?.isReleasedWhenClosed = false
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        popover?.performClose(nil)
    }

    // MARK: - Onboarding

    private func showOnboarding() {
        let onboardingView = OnboardingView()

        onboardingWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 520),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        onboardingWindow?.title = "Willkommen"
        onboardingWindow?.center()
        onboardingWindow?.contentView = NSHostingView(rootView: onboardingView)
        onboardingWindow?.isReleasedWhenClosed = false

        onboardingWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Observe onboarding completion
        onboardingManager.$isOnboardingComplete
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in
                self?.onboardingWindow?.close()
                self?.onboardingWindow = nil
                self?.startEventTap()
            }
            .store(in: &cancellables)
    }

    // MARK: - Event Tap

    private func startEventTap() {
        guard accessibilityService.isAccessibilityEnabled else {
            return
        }

        guard settingsManager.isEnabled else {
            return
        }

        eventTapService.start()
    }

    // MARK: - Bindings

    private func setupBindings() {
        // Update menu bar icon based on cut state
        cutStateManager.$cutState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateMenuBarIcon(isCutActive: state.isActive)
            }
            .store(in: &cancellables)

        // Restart event tap when accessibility permission changes
        accessibilityService.$isAccessibilityEnabled
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                if isEnabled {
                    self?.eventTapService.restart()
                } else {
                    self?.eventTapService.stop()
                }
            }
            .store(in: &cancellables)

        // Start/stop event tap based on enabled setting
        settingsManager.$settings
            .map { $0.isEnabled }
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                if isEnabled {
                    self?.eventTapService.restart()
                } else {
                    self?.eventTapService.stop()
                }
            }
            .store(in: &cancellables)

        // Show rating prompt when requested
        ratingService.$shouldShowPrompt
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showRatingPrompt()
            }
            .store(in: &cancellables)
    }

    private func updateMenuBarIcon(isCutActive: Bool) {
        let iconName = isCutActive ? Constants.MenuBar.iconCutActive : Constants.MenuBar.iconDefault

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Cut & Paste")

            if isCutActive {
                button.contentTintColor = .systemGreen
            } else {
                button.contentTintColor = nil
            }
        }
    }

    // MARK: - Toast

    private func setupToastCallbacks() {
        eventTapService.onCutPerformed = { [weak self] in
            guard self?.settingsManager.showVisualFeedback == true else { return }
            ToastWindowController.shared.show(message: "Ausgeschnitten", icon: "scissors")
        }

        eventTapService.onPastePerformed = { [weak self] in
            guard self?.settingsManager.showVisualFeedback == true else { return }
            ToastWindowController.shared.show(message: "Verschoben", icon: "checkmark.circle.fill")
        }
    }

    // MARK: - Rating

    private func showRatingPrompt() {
        let ratingView = RatingPromptView(ratingService: ratingService)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Feedback"
        window.center()
        window.contentView = NSHostingView(rootView: ratingView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        popover?.performClose(nil)
    }
}
