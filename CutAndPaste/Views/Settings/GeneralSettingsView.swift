import SwiftUI

struct GeneralSettingsView: View {

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Main Feature Toggle
                SettingsCard {
                    SettingsToggleRow(
                        icon: "scissors",
                        iconColor: .accentColor,
                        title: "settings.general.enable".localized,
                        subtitle: "settings.general.enable.help".localized,
                        isOn: Binding(
                            get: { viewModel.isEnabled },
                            set: { viewModel.updateIsEnabled($0) }
                        )
                    )
                }

                // App Behavior
                SettingsCard {
                    VStack(spacing: 0) {
                        SettingsToggleRow(
                            icon: "arrow.up.right.square",
                            iconColor: .blue,
                            title: "settings.general.launch_at_login".localized,
                            subtitle: "settings.general.launch_at_login.help".localized,
                            isOn: Binding(
                                get: { viewModel.launchAtLogin },
                                set: { viewModel.updateLaunchAtLogin($0) }
                            )
                        )

                        Divider()
                            .padding(.leading, 44)

                        SettingsToggleRow(
                            icon: "eye",
                            iconColor: .purple,
                            title: "settings.general.visual_feedback".localized,
                            subtitle: "settings.general.visual_feedback.help".localized,
                            isOn: Binding(
                                get: { viewModel.showVisualFeedback },
                                set: { viewModel.updateShowVisualFeedback($0) }
                            )
                        )
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Settings Card Component

struct SettingsCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 0.5)
            )
    }
}

// MARK: - Settings Toggle Row Component

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(CompactToggleStyle())
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
            .frame(width: 450, height: 300)
    }
}
#endif
