import SwiftUI

struct GeneralSettingsView: View {

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("settings.general.enable".localized, isOn: Binding(
                get: { viewModel.isEnabled },
                set: { viewModel.updateIsEnabled($0) }
            ))
            .help("settings.general.enable.help".localized)

            Toggle("settings.general.launch_at_login".localized, isOn: Binding(
                get: { viewModel.launchAtLogin },
                set: { viewModel.updateLaunchAtLogin($0) }
            ))
            .help("settings.general.launch_at_login.help".localized)

            Toggle("settings.general.visual_feedback".localized, isOn: Binding(
                get: { viewModel.showVisualFeedback },
                set: { viewModel.updateShowVisualFeedback($0) }
            ))
            .help("settings.general.visual_feedback.help".localized)

            Spacer()
        }
        .padding(20)
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
