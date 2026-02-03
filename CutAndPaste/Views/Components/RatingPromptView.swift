import SwiftUI

struct RatingPromptView: View {

    @ObservedObject var ratingService: RatingService
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)

                Text("Gefällt dir Cut & Paste?")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Dein Feedback hilft uns, die App zu verbessern.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Buttons
            VStack(spacing: 12) {
                Button(action: handlePositive) {
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                        Text("Ja, die App ist toll!")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button(action: handleNegative) {
                    HStack {
                        Image(systemName: "hand.thumbsdown")
                        Text("Nein, ich habe Verbesserungsvorschläge")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())

                Button("Später erinnern") {
                    handleSkip()
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.secondary)
            }

            #if DEBUG
            // Debug info
            VStack(spacing: 4) {
                Divider()
                Text("Debug: Skip Count = \(ratingService.state.skipCount)/\(Constants.Rating.maxSkipCount)")
                    .font(.caption2)
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            .padding(.top, 8)
            #endif
        }
        .padding(32)
        .frame(width: 400)
    }

    // MARK: - Actions

    private func handlePositive() {
        ratingService.handlePositiveResponse()
        presentationMode.wrappedValue.dismiss()
    }

    private func handleNegative() {
        ratingService.handleNegativeResponse()
        presentationMode.wrappedValue.dismiss()
    }

    private func handleSkip() {
        ratingService.handleSkip()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Custom Button Styles for macOS 11

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#if DEBUG
struct RatingPromptView_Previews: PreviewProvider {
    static var previews: some View {
        RatingPromptView(ratingService: RatingService.shared)
    }
}
#endif
