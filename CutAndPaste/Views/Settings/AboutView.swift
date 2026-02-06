import SwiftUI

struct AboutView: View {

    @StateObject private var viewModel = SettingsViewModel()
    @State private var isHoveredFeedback = false
    @State private var isHoveredAppStore = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Icon and Name
                VStack(spacing: 12) {
                    // App Icon
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 72, height: 72)

                        Circle()
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            .frame(width: 72, height: 72)

                        Image(systemName: "scissors")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.accentColor)
                    }

                    VStack(spacing: 4) {
                        Text("app.name".localized)
                            .font(.system(size: 18, weight: .bold))

                        Text("about.version".localized(with: viewModel.appVersion))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                // Action Buttons
                VStack(spacing: 10) {
                    AboutActionButton(
                        icon: "envelope.fill",
                        title: "about.feedback".localized,
                        subtitle: "about.feedback.subtitle".localized,
                        color: .blue,
                        isHovered: $isHoveredFeedback,
                        action: viewModel.sendFeedback
                    )

                    AboutActionButton(
                        icon: "star.fill",
                        title: "about.rate".localized,
                        subtitle: "about.rate.subtitle".localized,
                        color: .orange,
                        isHovered: $isHoveredAppStore,
                        action: viewModel.openAppStore
                    )
                }

                // Copyright
                VStack(spacing: 4) {
                    Text("about.made_with_love".localized)
                        .font(.system(size: 10))
                        .foregroundColor(.tertiaryLabel)

                    Text("about.copyright".localized(with: "2026"))
                        .font(.system(size: 10))
                        .foregroundColor(.tertiaryLabel)
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
    }
}

// MARK: - About Action Button

struct AboutActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @Binding var isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(isHovered ? 0.2 : 0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.tertiaryLabel)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isHovered ? color.opacity(0.3) : Color(NSColor.separatorColor).opacity(0.5), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#if DEBUG
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 450, height: 300)
    }
}
#endif
