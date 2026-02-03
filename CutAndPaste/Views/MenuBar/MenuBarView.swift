import SwiftUI

struct MenuBarView: View {

    @StateObject private var viewModel = MenuBarViewModel()
    @EnvironmentObject private var ratingService: RatingService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            statusSection
            Divider()
            controlsSection
            Divider()
            actionsSection
        }
        .padding()
        .frame(width: 260)
    }

    // MARK: - Sections

    private var statusSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(viewModel.statusColor).opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: viewModel.menuBarIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(viewModel.statusColor))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("app.name".localized)
                    .font(.headline)

                Text(viewModel.statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Permission warning banner
            if !viewModel.isAccessibilityEnabled {
                Button(action: viewModel.openAccessibilitySettings) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("permission.banner.title".localized)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("permission.banner.subtitle".localized)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            Toggle("menubar.toggle.enabled".localized, isOn: Binding(
                get: { viewModel.isEnabled },
                set: { _ in viewModel.toggleEnabled() }
            ))
            .toggleStyle(ColoredSwitchToggleStyle(onColor: .green))
            .disabled(!viewModel.isAccessibilityEnabled)
            .opacity(viewModel.isAccessibilityEnabled ? 1 : 0.5)

            if viewModel.isCutModeActive {
                HStack {
                    Image(systemName: "scissors")
                        .foregroundColor(.green)
                    Text("menubar.cut_mode.files_ready".localized)
                        .font(.caption)
                    Spacer()
                    Button("menubar.cut_mode.cancel".localized) {
                        viewModel.clearCutMode()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: viewModel.openSettings) {
                HStack {
                    Image(systemName: "gear")
                    Text("menubar.action.settings".localized)
                    Spacer()
                }
            }
            .buttonStyle(.borderless)

            Button(action: viewModel.quit) {
                HStack {
                    Image(systemName: "power")
                    Text("menubar.action.quit".localized)
                    Spacer()
                }
            }
            .buttonStyle(.borderless)
        }
    }
}

#if DEBUG
struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
            .environmentObject(RatingService.shared)
    }
}
#endif
