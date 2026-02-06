import SwiftUI

#if DEBUG
struct DebugSettingsView: View {

    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var ratingService = RatingService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Cut State Section
                DebugCard(
                    icon: "scissors",
                    iconColor: .green,
                    title: "Cut State"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.cutStateDebugInfo)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            DebugButton(title: "Activate", color: .green) {
                                CutStateManager.shared.forceActivate()
                            }
                            DebugButton(title: "Deactivate", color: .secondary) {
                                CutStateManager.shared.forceDeactivate()
                            }
                        }
                    }
                }

                // Rating State Section
                DebugCard(
                    icon: "star.fill",
                    iconColor: .yellow,
                    title: "Rating State"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.ratingDebugInfo)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)

                        Divider()

                        HStack(spacing: 8) {
                            DebugButton(title: "Trigger", color: .blue) {
                                viewModel.triggerRatingPrompt()
                            }
                            DebugButton(title: "Reset", color: .red) {
                                viewModel.resetRatingState()
                            }
                        }
                    }
                }

                // App Info Section
                DebugCard(
                    icon: "info.circle.fill",
                    iconColor: .blue,
                    title: "App Info"
                ) {
                    VStack(spacing: 4) {
                        DebugInfoRow(label: "Version", value: Constants.App.version)
                        DebugInfoRow(label: "Build", value: Constants.App.build)
                        DebugInfoRow(label: "Bundle ID", value: Constants.App.bundleIdentifier)
                        DebugInfoRow(label: "macOS", value: Constants.Device.macOSVersion)
                        DebugInfoRow(label: "Device", value: Constants.Device.deviceModel)
                    }
                }

                // Onboarding Section
                DebugCard(
                    icon: "hand.wave.fill",
                    iconColor: .purple,
                    title: "Onboarding"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Completed:")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(SettingsManager.shared.hasCompletedOnboarding ? "Yes" : "No")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(SettingsManager.shared.hasCompletedOnboarding ? .green : .orange)
                        }

                        DebugButton(title: "Reset Onboarding", color: .red) {
                            SettingsManager.shared.hasCompletedOnboarding = false
                            OnboardingManager.shared.reset()
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Debug Card Component

struct DebugCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: Content

    init(icon: String, iconColor: Color, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))

                Spacer()
            }

            content
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 0.5)
        )
    }
}

// MARK: - Debug Button

struct DebugButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(color.opacity(0.1))
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Debug Info Row

struct DebugInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}

struct DebugSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DebugSettingsView()
            .frame(width: 450, height: 500)
    }
}
#endif
