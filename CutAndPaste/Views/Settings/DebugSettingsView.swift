import SwiftUI

#if DEBUG
struct DebugSettingsView: View {

    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var ratingService = RatingService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Cut State Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cut State")
                        .font(.headline)

                    Text(viewModel.cutStateDebugInfo)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)

                    HStack {
                        Button("Activate") {
                            CutStateManager.shared.forceActivate()
                        }
                        Button("Deactivate") {
                            CutStateManager.shared.forceDeactivate()
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)

                // Rating State Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating State")
                        .font(.headline)

                    Text(viewModel.ratingDebugInfo)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)

                    Divider()

                    HStack {
                        Button("Trigger Prompt") {
                            viewModel.triggerRatingPrompt()
                        }

                        Button("Reset State") {
                            viewModel.resetRatingState()
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)

                // App Info Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("App Info")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 4) {
                        InfoRow(label: "Version", value: Constants.App.version)
                        InfoRow(label: "Build", value: Constants.App.build)
                        InfoRow(label: "Bundle ID", value: Constants.App.bundleIdentifier)
                        InfoRow(label: "macOS", value: Constants.Device.macOSVersion)
                        InfoRow(label: "Device", value: Constants.Device.deviceModel)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)

                // Onboarding Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Onboarding")
                        .font(.headline)

                    Text("Has completed: \(SettingsManager.shared.hasCompletedOnboarding ? "Yes" : "No")")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)

                    Button("Reset Onboarding") {
                        SettingsManager.shared.hasCompletedOnboarding = false
                        OnboardingManager.shared.reset()
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
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
