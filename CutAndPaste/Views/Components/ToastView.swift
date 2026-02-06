import SwiftUI
import AppKit

struct ToastView: View {

    let message: String
    let icon: String
    @Binding var isShowing: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.85))
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .opacity(isShowing ? 1 : 0)
        .scaleEffect(isShowing ? 1 : 0.8)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowing)
    }
}

// MARK: - Toast Window Controller

final class ToastWindowController {

    static let shared = ToastWindowController()

    private var window: NSWindow?
    private var dismissWorkItem: DispatchWorkItem?

    private init() {}

    func show(message: String, icon: String = "checkmark.circle.fill", duration: TimeInterval = 1.5) {
        DispatchQueue.main.async {
            self.createAndShowWindow(message: message, icon: icon, duration: duration)
        }
    }

    private func createAndShowWindow(message: String, icon: String, duration: TimeInterval) {
        // Dismiss any existing toast
        dismissExistingWindow()

        // Create content view
        let contentView = ToastContentView(message: message, icon: icon)

        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 250, height: 60),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        let hostingView = NSHostingView(rootView: contentView)
        window.contentView = hostingView

        // Position at bottom center of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowWidth: CGFloat = 250
            let windowHeight: CGFloat = 60
            let x = screenFrame.midX - windowWidth / 2
            let y = screenFrame.minY + 100

            window.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
        }

        self.window = window
        window.orderFront(nil)

        // Animate in
        window.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 1
        }

        // Schedule dismiss (cancel any previous pending dismiss)
        dismissWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    private func dismiss() {
        guard let window = self.window else { return }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            window.animator().alphaValue = 0
        }, completionHandler: {
            window.orderOut(nil)
            self.window = nil
        })
    }

    private func dismissExistingWindow() {
        window?.orderOut(nil)
        window = nil
    }
}

// MARK: - Toast Content View (for NSHostingView)

private struct ToastContentView: View {
    let message: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.85))
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#if DEBUG
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToastView(
                message: "Ausgeschnitten",
                icon: "scissors",
                isShowing: .constant(true)
            )

            ToastView(
                message: "Verschoben",
                icon: "checkmark.circle.fill",
                isShowing: .constant(true)
            )
        }
        .padding(50)
        .background(Color.gray.opacity(0.3))
    }
}
#endif
