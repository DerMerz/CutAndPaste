import SwiftUI

struct AboutView: View {

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // App Icon and Name
            VStack(spacing: 12) {
                Image(systemName: "scissors")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)

                Text("Cut & Paste")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version \(viewModel.appVersion)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Links
            VStack(spacing: 8) {
                Button(action: viewModel.sendFeedback) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Feedback senden")
                    }
                }
                .buttonStyle(.borderless)

                Button(action: viewModel.openAppStore) {
                    HStack {
                        Image(systemName: "star")
                        Text("Im App Store bewerten")
                    }
                }
                .buttonStyle(.borderless)
            }

            Spacer()

            // Copyright
            Text("© 2024 Kevin Merz")
                .font(.caption2)
                .foregroundColor(.tertiaryLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
