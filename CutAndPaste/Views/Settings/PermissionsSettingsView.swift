import SwiftUI

struct PermissionsSettingsView: View {

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Accessibility Permission Card
                SettingsCard {
                    VStack(spacing: 16) {
                        // Header with status
                        HStack(spacing: 12) {
                            // Icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(statusColor.opacity(0.15))
                                    .frame(width: 40, height: 40)

                                Image(systemName: viewModel.isAccessibilityEnabled ? "checkmark.shield.fill" : "hand.raised.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(statusColor)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("settings.permissions.accessibility".localized)
                                    .font(.system(size: 14, weight: .semibold))

                                Text("settings.permissions.accessibility.description".localized)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Status Badge
                            statusBadge
                        }

                        // Action Section (only when not granted)
                        if !viewModel.isAccessibilityEnabled {
                            Divider()

                            VStack(alignment: .leading, spacing: 12) {
                                // Explanation
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 12))
                                        .padding(.top, 2)

                                    Text("settings.permissions.accessibility.explanation".localized)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                // Button
                                Button(action: viewModel.openAccessibilityPreferences) {
                                    HStack {
                                        Image(systemName: "gear")
                                        Text("settings.permissions.open_settings".localized)
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // How It Works (shown when permission is granted)
                if viewModel.isAccessibilityEnabled {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label {
                                Text("settings.permissions.how_it_works".localized)
                                    .font(.system(size: 12, weight: .semibold))
                            } icon: {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                            }

                            Text("settings.permissions.how_it_works.description".localized)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private var statusColor: Color {
        viewModel.isAccessibilityEnabled ? .green : .orange
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.isAccessibilityEnabled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 10))

            Text(viewModel.isAccessibilityEnabled ? "settings.permissions.status.granted".localized : "settings.permissions.status.not_granted".localized)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.15))
        )
    }
}

#if DEBUG
struct PermissionsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsSettingsView()
            .frame(width: 450, height: 300)
    }
}
#endif
