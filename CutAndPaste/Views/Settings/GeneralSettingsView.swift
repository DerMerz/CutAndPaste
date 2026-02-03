import SwiftUI

struct GeneralSettingsView: View {

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Cut & Paste aktivieren", isOn: Binding(
                get: { viewModel.isEnabled },
                set: { viewModel.updateIsEnabled($0) }
            ))
            .help("Aktiviert oder deaktiviert die Cut & Paste Funktion")

            Toggle("Bei Anmeldung starten", isOn: Binding(
                get: { viewModel.launchAtLogin },
                set: { viewModel.updateLaunchAtLogin($0) }
            ))
            .help("Cut & Paste wird automatisch beim Anmelden gestartet")

            Toggle("Visuelles Feedback anzeigen", isOn: Binding(
                get: { viewModel.showVisualFeedback },
                set: { viewModel.updateShowVisualFeedback($0) }
            ))
            .help("Zeigt eine Benachrichtigung beim Ausschneiden und Einfügen")

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
