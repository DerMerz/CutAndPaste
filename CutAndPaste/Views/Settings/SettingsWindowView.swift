import SwiftUI

struct SettingsWindowView: View {

    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable {
        case general
        case permissions
        case about
        #if DEBUG
        case debug
        #endif

        var title: String {
            switch self {
            case .general:
                return "settings.tab.general".localized
            case .permissions:
                return "settings.tab.permissions".localized
            case .about:
                return "settings.tab.about".localized
            #if DEBUG
            case .debug:
                return "settings.tab.debug".localized
            #endif
            }
        }

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
                    Label(SettingsTab.general.title, systemImage: SettingsTab.general.icon)
                }
                .tag(SettingsTab.general)

            PermissionsSettingsView()
                .tabItem {
                    Label(SettingsTab.permissions.title, systemImage: SettingsTab.permissions.icon)
                }
                .tag(SettingsTab.permissions)

            AboutView()
                .tabItem {
                    Label(SettingsTab.about.title, systemImage: SettingsTab.about.icon)
                }
                .tag(SettingsTab.about)

            #if DEBUG
            DebugSettingsView()
                .tabItem {
                    Label(SettingsTab.debug.title, systemImage: SettingsTab.debug.icon)
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
