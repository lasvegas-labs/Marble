import FamilyControls
import SwiftUI

struct SetupProfileView: View {
    @StateObject private var viewModel: SetupProfileViewModel

    private let onComplete: () -> Void
    private let onBackToIntroduction: () -> Void

    init(
        viewModel: SetupProfileViewModel,
        onComplete: @escaping () -> Void,
        onBackToIntroduction: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
        self.onBackToIntroduction = onBackToIntroduction
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader

            ScrollView {
                stepContent
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)

            continueButton
        }
        .background(Color(.systemBackground))
        .toolbarVisibility(.hidden, for: .navigationBar)
        .familyActivityPicker(
            headerText: "Choose the apps and categories that distract you most.",
            footerText: "Marble only receives privacy-preserving tokens for your selection.",
            isPresented: $viewModel.isActivityPickerPresented,
            selection: $viewModel.activitySelection
        )
        .alert(
            "Setup Profile",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
        .animation(.smooth, value: viewModel.currentStep)
    }

    private var navigationHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 42, height: 42)
                        .background(Color(uiColor: .systemGray6))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    viewModel.currentStep == .gender
                        ? "Back to introduction"
                        : "Previous step"
                )

                HStack(spacing: 4) {
                    ForEach(SetupProfileStep.allCases, id: \.rawValue) { step in
                        Capsule()
                            .fill(
                                step.rawValue <= viewModel.currentStep.rawValue
                                    ? Color.primary
                                    : Color.secondary.opacity(0.2)
                            )
                            .frame(height: 5)
                    }
                }

                Button("Skip", action: skipAction)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            Text("\(viewModel.stepNumber) of \(viewModel.stepCount) Steps")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel(
                    "Step \(viewModel.stepNumber) of \(viewModel.stepCount)"
                )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .gender:
            GenderStepView(viewModel: viewModel)
        case .ageRange:
            AgeRangeStepView(viewModel: viewModel)
        case .background:
            BackgroundStepView(
                viewModel: viewModel,
                onPreferNotToSay: continueAction
            )
        case .interests:
            InterestsStepView(viewModel: viewModel)
        case .screenTimePermission:
            ScreenTimePermissionStepView(viewModel: viewModel)
        case .distractingApps:
            DistractingAppsStepView(viewModel: viewModel)
        case .focusWindow:
            FocusWindowStepView(viewModel: viewModel)
        case .orbPersona:
            OrbPersonaStepView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        Button(action: continueAction) {
            HStack(spacing: 8) {
                if viewModel.isWorking {
                    ProgressView()
                }
                Text(continueButtonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(viewModel.isWorking)
        .controlSize(.extraLarge)
        .buttonStyle(.glass)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var continueButtonTitle: String {
        switch viewModel.currentStep {
        case .screenTimePermission: "Allow & Continue"
        case .orbPersona: "Finish"
        default: "Continue"
        }
    }

    private func backAction() {
        if viewModel.currentStep == .gender {
            onBackToIntroduction()
        } else {
            _ = viewModel.goBack()
        }
    }

    private func continueAction() {
        let isFinalStep = viewModel.currentStep == .orbPersona
        Task {
            if await viewModel.continueCurrentStep(), isFinalStep {
                onComplete()
            }
        }
    }

    private func skipAction() {
        let isFinalStep = viewModel.currentStep == .orbPersona
        if viewModel.skipCurrentStep(), isFinalStep {
            onComplete()
        }
    }
}
