import Foundation
import Combine

final class CutStateManager: ObservableObject {

    static let shared = CutStateManager()

    @Published private(set) var cutState: CutState = .inactive

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupObservers()
    }

    // MARK: - Public Methods

    func activateCutMode(fileCount: Int? = nil) {
        let operation = CutOperation(fileCount: fileCount)
        cutState = .active(operation)
        NotificationCenter.default.post(name: Constants.Notifications.cutModeDidChange, object: nil)
    }

    func deactivateCutMode() {
        guard cutState.isActive else { return }
        cutState = .inactive
        NotificationCenter.default.post(name: Constants.Notifications.cutModeDidChange, object: nil)
    }

    func toggle() {
        if cutState.isActive {
            deactivateCutMode()
        } else {
            activateCutMode()
        }
    }

    // MARK: - Debug Methods

    #if DEBUG
    func forceActivate() {
        activateCutMode()
    }

    func forceDeactivate() {
        deactivateCutMode()
    }
    #endif

    // MARK: - Private Methods

    private func setupObservers() {
        // Clear cut state if it becomes stale (after 5 minutes)
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAndClearStaleState()
            }
            .store(in: &cancellables)
    }

    private func checkAndClearStaleState() {
        guard case .active(let operation) = cutState else { return }

        if !operation.isRecent {
            deactivateCutMode()
        }
    }
}
