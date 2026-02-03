import AppKit
import Combine

final class FinderMonitorService: ObservableObject {

    static let shared = FinderMonitorService()

    @Published private(set) var isFinderActive: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupObservers()
        checkFinderStatus()
    }

    // MARK: - Public Methods

    func checkFinderStatus() {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            isFinderActive = false
            return
        }

        isFinderActive = frontmostApp.bundleIdentifier == Constants.Finder.bundleIdentifier
    }

    // MARK: - Private Methods

    private func setupObservers() {
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] notification in
                self?.handleAppActivation(notification)
            }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didDeactivateApplicationNotification)
            .sink { [weak self] _ in
                self?.checkFinderStatus()
            }
            .store(in: &cancellables)
    }

    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }

        isFinderActive = app.bundleIdentifier == Constants.Finder.bundleIdentifier
    }
}
