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

        static var allVisibleCases: [SettingsTab] {
            #if DEBUG
            return [.general, .permissions, .about, .debug]
            #else
            return [.general, .permissions, .about]
            #endif
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 2) {
                ForEach(SettingsTab.allVisibleCases, id: \.self) { tab in
                    SettingsTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Content
            Group {
                switch selectedTab {
                case .general:
                    GeneralSettingsView()
                case .permissions:
                    PermissionsSettingsView()
                case .about:
                    AboutView()
                #if DEBUG
                case .debug:
                    DebugSettingsView()
                #endif
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 460, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Tab Button

struct SettingsTabButton: View {
    let tab: SettingsWindowView.SettingsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct SettingsWindowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsWindowView()
    }
}
#endif
