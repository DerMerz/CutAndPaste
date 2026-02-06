import SwiftUI

struct OnboardingView: View {

    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator with smooth animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(NSColor.separatorColor).opacity(0.3))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * viewModel.progress, height: 4)
                        .animation(.easeInOut(duration: 0.4), value: viewModel.progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 40)
            .padding(.top, 20)

            // Content
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
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
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
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showIcon ? 1 : 0.5)
                    .opacity(showIcon ? 1 : 0)

                Image(systemName: "scissors")
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(.accentColor)
                    .scaleEffect(showIcon ? 1 : 0)
                    .rotationEffect(.degrees(showIcon ? 0 : -30))
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showIcon)

            Text("onboarding.welcome.title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 15)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showTitle)

            Text("onboarding.welcome.subtitle".localized)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .opacity(showSubtitle ? 1 : 0)
                .offset(y: showSubtitle ? 0 : 10)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showSubtitle)

            Spacer()
        }
        .padding(40)
        .onAppear {
            showIcon = true
            showTitle = true
            showSubtitle = true
        }
    }
}

struct HowItWorksStepView: View {
    @State private var visibleSteps: Set<Int> = []

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
                    description: "onboarding.howitworks.step1.description".localized,
                    isVisible: visibleSteps.contains(1)
                )

                StepRow(
                    number: 2,
                    icon: "command",
                    title: "onboarding.howitworks.step2.title".localized,
                    description: "onboarding.howitworks.step2.description".localized,
                    isVisible: visibleSteps.contains(2)
                )

                StepRow(
                    number: 3,
                    icon: "folder",
                    title: "onboarding.howitworks.step3.title".localized,
                    description: "onboarding.howitworks.step3.description".localized,
                    isVisible: visibleSteps.contains(3)
                )

                StepRow(
                    number: 4,
                    icon: "arrow.right.doc.on.clipboard",
                    title: "onboarding.howitworks.step4.title".localized,
                    description: "onboarding.howitworks.step4.description".localized,
                    isVisible: visibleSteps.contains(4)
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(40)
        .onAppear {
            for i in 1...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        _ = visibleSteps.insert(i)
                    }
                }
            }
        }
    }
}

struct StepRow: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    var isVisible: Bool = true

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
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
    }
}

struct PermissionStepView: View {
    let isGranted: Bool
    let isChecking: Bool
    let onRequestPermission: () -> Void

    @State private var pulseAnimation = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                // Pulse ring when waiting for permission
                if !isGranted && !isChecking {
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseAnimation ? 1.15 : 1)
                        .opacity(pulseAnimation ? 0 : 0.8)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                }

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
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isGranted)

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
                Button(action: onRequestPermission) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                        Text("onboarding.permission.button".localized)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(40)
        .onAppear {
            pulseAnimation = true
        }
    }
}

struct SuccessStepView: View {
    @Binding var launchAtLogin: Bool
    let onToggleLaunchAtLogin: (Bool) -> Void

    @State private var showCheckmark = false
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(showCheckmark ? 1 : 0.8)

                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.green)
                    .scaleEffect(showCheckmark ? 1 : 0)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheckmark)

            VStack(spacing: 16) {
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
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)

            Spacer()
        }
        .padding(40)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showCheckmark = true
            }
            showContent = true
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
