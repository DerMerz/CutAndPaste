import SwiftUI

struct PermissionsSettingsView: View {

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("settings.permissions.accessibility".localized)
                        .font(.headline)

                    Text("settings.permissions.accessibility.description".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                statusBadge
            }

            if !viewModel.isAccessibilityEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("settings.permissions.accessibility.explanation".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("settings.permissions.open_settings".localized) {
                        viewModel.openAccessibilityPreferences()
                    }
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding(20)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.isAccessibilityEnabled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(viewModel.isAccessibilityEnabled ? .green : .orange)

            Text(viewModel.isAccessibilityEnabled ? "settings.permissions.status.granted".localized : "settings.permissions.status.not_granted".localized)
                .font(.caption)
                .foregroundColor(viewModel.isAccessibilityEnabled ? .green : .orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(viewModel.isAccessibilityEnabled ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
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
