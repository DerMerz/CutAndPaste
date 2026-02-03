import SwiftUI

struct SettingsWindowView: View {

    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable {
        case general = "Allgemein"
        case permissions = "Berechtigungen"
        case about = "Über"
        #if DEBUG
        case debug = "Debug"
        #endif

        var icon: String {
            switch self {
            case .general:
                return "gear"
            case .permissions:
                return "hand.raised"
            case .about:
                return "info.circle"
            #if DEBUG
            case .debug:
                return "ant"
            #endif
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label(SettingsTab.general.rawValue, systemImage: SettingsTab.general.icon)
                }
                .tag(SettingsTab.general)

            PermissionsSettingsView()
                .tabItem {
                    Label(SettingsTab.permissions.rawValue, systemImage: SettingsTab.permissions.icon)
                }
                .tag(SettingsTab.permissions)

            AboutView()
                .tabItem {
                    Label(SettingsTab.about.rawValue, systemImage: SettingsTab.about.icon)
                }
                .tag(SettingsTab.about)

            #if DEBUG
            DebugSettingsView()
                .tabItem {
                    Label(SettingsTab.debug.rawValue, systemImage: SettingsTab.debug.icon)
                }
                .tag(SettingsTab.debug)
            #endif
        }
        .frame(width: 450, height: 300)
    }
}

#if DEBUG
struct SettingsWindowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsWindowView()
    }
}
#endif
