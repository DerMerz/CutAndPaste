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
                    Button("onboarding.button.back".localized) {
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

            Text("onboarding.welcome.title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("onboarding.welcome.subtitle".localized)
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
            Text("onboarding.howitworks.title".localized)
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 20) {
                StepRow(
                    number: 1,
                    icon: "doc.on.doc",
                    title: "onboarding.howitworks.step1.title".localized,
                    description: "onboarding.howitworks.step1.description".localized
                )

                StepRow(
                    number: 2,
                    icon: "command",
                    title: "onboarding.howitworks.step2.title".localized,
                    description: "onboarding.howitworks.step2.description".localized
                )

                StepRow(
                    number: 3,
                    icon: "folder",
                    title: "onboarding.howitworks.step3.title".localized,
                    description: "onboarding.howitworks.step3.description".localized
                )

                StepRow(
                    number: 4,
                    icon: "arrow.right.doc.on.clipboard",
                    title: "onboarding.howitworks.step4.title".localized,
                    description: "onboarding.howitworks.step4.description".localized
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

            Text(isGranted ? "onboarding.permission.granted.title".localized : "onboarding.permission.required.title".localized)
                .font(.title)
                .fontWeight(.bold)

            Text(isGranted
                 ? "onboarding.permission.granted.description".localized
                 : "onboarding.permission.required.description".localized)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if !isGranted {
                Button("onboarding.permission.button".localized) {
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

            Text("onboarding.success.title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("onboarding.success.description".localized)
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
                            Text("onboarding.success.launch_at_login".localized)
                                .font(.body)
                            Text("onboarding.success.launch_at_login.recommended".localized)
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

                Text("onboarding.success.hint".localized)
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
