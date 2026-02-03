import SwiftUI

struct OnboardingView: View {

    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal, 40)
                .padding(.top, 20)

            // Content - use switch instead of TabView for better control
            Group {
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeStepView()
                case .howItWorks:
                    HowItWorksStepView()
                case .permission:
                    PermissionStepView(
                        isGranted: viewModel.isPermissionGranted,
                        isChecking: viewModel.isCheckingPermission,
                        onRequestPermission: viewModel.requestPermission
                    )
                case .success:
                    SuccessStepView(
                        launchAtLogin: $viewModel.launchAtLogin,
                        onToggleLaunchAtLogin: viewModel.updateLaunchAtLogin
                    )
                }
            }
            .frame(height: 400)
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)

            // Navigation buttons
            HStack {
                if viewModel.canGoBack {
                    Button("Zurück") {
                        viewModel.previous()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }

                Spacer()

                Button(viewModel.nextButtonTitle) {
                    if viewModel.currentStep.isLast {
                        viewModel.complete()
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        viewModel.next()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!viewModel.canGoNext && viewModel.currentStep != .permission)
            }
            .padding(20)
        }
        .frame(width: 500, height: 520)
    }
}

// MARK: - Step Views

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "scissors")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("Willkommen bei\nCut & Paste")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Endlich echtes Ausschneiden im Finder - wie bei Windows.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(40)
    }
}

struct HowItWorksStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("So funktioniert's")
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 20) {
                StepRow(
                    number: 1,
                    icon: "doc.on.doc",
                    title: "Dateien auswählen",
                    description: "Wähle eine oder mehrere Dateien im Finder aus"
                )

                StepRow(
                    number: 2,
                    icon: "command",
                    title: "Cmd+X drücken",
                    description: "Die Dateien werden zum Verschieben markiert"
                )

                StepRow(
                    number: 3,
                    icon: "folder",
                    title: "Zum Ziel navigieren",
                    description: "Öffne den Ordner, in den du verschieben möchtest"
                )

                StepRow(
                    number: 4,
                    icon: "arrow.right.doc.on.clipboard",
                    title: "Cmd+V drücken",
                    description: "Die Dateien werden verschoben (nicht kopiert!)"
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(40)
    }
}

struct StepRow: View {
    let number: Int
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(number). \(title)")
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct PermissionStepView: View {
    let isGranted: Bool
    let isChecking: Bool
    let onRequestPermission: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(isGranted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)

                if isChecking {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    Image(systemName: isGranted ? "checkmark.shield.fill" : "hand.raised.fill")
                        .font(.system(size: 44))
                        .foregroundColor(isGranted ? .green : .orange)
                }
            }

            Text(isGranted ? "Berechtigung erteilt" : "Berechtigung erforderlich")
                .font(.title)
                .fontWeight(.bold)

            Text(isGranted
                 ? "Cut & Paste hat jetzt Zugriff auf die Bedienungshilfen."
                 : "Cut & Paste benötigt die Bedienungshilfen-Berechtigung, um Tastatureingaben im Finder abzufangen.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if !isGranted {
                Button("Systemeinstellungen öffnen") {
                    onRequestPermission()
                }
            }

            Spacer()
        }
        .padding(40)
    }
}

struct SuccessStepView: View {
    @Binding var launchAtLogin: Bool
    let onToggleLaunchAtLogin: (Bool) -> Void

    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.green)
                    .scaleEffect(showCheckmark ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheckmark)
            }

            Text("Du bist bereit!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Cut & Paste läuft jetzt in deiner Menüleiste.\nDrücke Cmd+X im Finder, um loszulegen.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Launch at Login Toggle
            VStack(spacing: 12) {
                Divider()
                    .padding(.horizontal, 40)

                Toggle(isOn: Binding(
                    get: { launchAtLogin },
                    set: { onToggleLaunchAtLogin($0) }
                )) {
                    HStack(spacing: 12) {
                        Image(systemName: "power")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bei Anmeldung starten")
                                .font(.body)
                            Text("Empfohlen für nahtloses Arbeiten")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .toggleStyle(ColoredSwitchToggleStyle(onColor: .green))
                .padding(.horizontal, 40)
            }

            HStack(spacing: 8) {
                Image(systemName: "menubar.rectangle")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Das Scheren-Symbol findest du oben rechts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(40)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showCheckmark = true
            }
        }
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif
