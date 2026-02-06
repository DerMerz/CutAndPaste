import AppKit
import SwiftUI

// MARK: - NSApplication Extensions

extension NSApplication {

    static func openSystemPreferences(at url: String) {
        guard let url = URL(string: url) else { return }
        NSWorkspace.shared.open(url)
    }

    static func openAccessibilityPreferences() {
        openSystemPreferences(at: Constants.URLs.accessibilityPreferences)
    }

    static func composeFeedbackEmail() {
        let subject = "feedback.email.subject".localized
        let body = """
        ---
        \(Constants.Device.systemInfo)
        """

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "mailto:\(Constants.App.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)"

        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - View Extensions

extension View {

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
    }
}

// MARK: - Date Extensions

extension Date {

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date.startOfDay, to: self.startOfDay)
        return components.day ?? 0
    }

    func isOnSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {

    func date(forKey key: String) -> Date? {
        object(forKey: key) as? Date
    }

    func setDate(_ date: Date?, forKey key: String) {
        set(date, forKey: key)
    }
}

// MARK: - Color Extensions

extension Color {

    static var accentGreen: Color {
        Color.green
    }

    static var accentOrange: Color {
        Color.orange
    }

    static var secondaryLabel: Color {
        Color(NSColor.secondaryLabelColor)
    }

    static var tertiaryLabel: Color {
        Color(NSColor.tertiaryLabelColor)
    }
}

// MARK: - CGKeyCode Extensions

extension CGKeyCode {
    static let kVK_ANSI_X: CGKeyCode = 0x07
    static let kVK_ANSI_V: CGKeyCode = 0x09
    static let kVK_ANSI_C: CGKeyCode = 0x08
}

// MARK: - CGEventFlags Extensions

extension CGEventFlags {

    var hasCommand: Bool {
        contains(.maskCommand)
    }

    var hasShift: Bool {
        contains(.maskShift)
    }

    var hasOption: Bool {
        contains(.maskAlternate)
    }

    var hasControl: Bool {
        contains(.maskControl)
    }

    var isOnlyCommand: Bool {
        let modifierMask: CGEventFlags = [.maskCommand, .maskShift, .maskAlternate, .maskControl]
        let activeModifiers = self.intersection(modifierMask)
        return activeModifiers == .maskCommand
    }
}

// MARK: - Binding Extensions

extension Binding where Value == Bool {

    init<T>(value: Binding<T?>) {
        self.init(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
}

// MARK: - String Localization Extension

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Custom Toggle Style

struct ColoredSwitchToggleStyle: ToggleStyle {
    var onColor: Color = .green
    var offColor: Color = Color(NSColor.separatorColor)
    var thumbColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 44, height: 26)

                Circle()
                    .fill(thumbColor)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .frame(width: 22, height: 22)
                    .padding(2)
            }
            .animation(.spring(response: 0.2, dampingFraction: 0.75), value: configuration.isOn)
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

// MARK: - Compact Toggle Style (for Settings rows)

struct CompactToggleStyle: ToggleStyle {
    var onColor: Color = .green

    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: configuration.isOn ? .trailing : .leading) {
            Capsule()
                .fill(configuration.isOn ? onColor : Color(NSColor.separatorColor))
                .frame(width: 38, height: 22)

            Circle()
                .fill(.white)
                .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
                .frame(width: 18, height: 18)
                .padding(2)
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: configuration.isOn)
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
