//
//  SettingsView.swift
//  Marble
//
//  Created by otnielkalit on 11/08/26.
//

import SwiftData
import SwiftUI

struct EditProfileContainerView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: SetupProfileViewModel

    init(modelContext: ModelContext) {
        _viewModel = StateObject(
            wrappedValue: SetupProfileViewModel(
                modelContext: modelContext,
                screenTimeService: ScreenTimeService()
            )
        )
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

            saveButton
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            "Edit Profile",
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
        .onAppear {
            viewModel.resetToFirstStep()
        }
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
                .accessibilityLabel("Back")

                HStack(spacing: 4) {
                    ForEach(profileSteps, id: \.rawValue) { step in
                        Capsule()
                            .fill(
                                step.rawValue <= viewModel.currentStep.rawValue
                                    ? Color.primary
                                    : Color.secondary.opacity(0.2)
                            )
                            .frame(height: 5)
                    }
                }
            }

            Text("Edit Profile • Step \(currentStepIndex + 1) of \(profileSteps.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
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
                onPreferNotToSay: saveAndAdvance
            )
        case .interests:
            InterestsStepView(viewModel: viewModel)
        default:
            GenderStepView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private var saveButton: some View {
        if #available(iOS 26, *) {
            saveButtonContent
                .buttonStyle(.glass)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        } else {
            saveButtonContent
                .buttonStyle(.bordered)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
    }

    private var saveButtonContent: some View {
        Button(action: saveAndAdvance) {
            HStack(spacing: 8) {
                if viewModel.isWorking {
                    ProgressView()
                }
                Text(isFinalEditStep ? "Save Profile" : "Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(viewModel.isWorking)
        .controlSize(.extraLarge)
    }

    private var profileSteps: [SetupProfileStep] {
        [.gender, .ageRange, .background, .interests]
    }

    private var currentStepIndex: Int {
        profileSteps.firstIndex(of: viewModel.currentStep) ?? 0
    }

    private var isFinalEditStep: Bool {
        viewModel.currentStep == .interests
    }

    private func backAction() {
        if viewModel.currentStep == .gender {
            router.pop()
        } else {
            _ = viewModel.goBack()
        }
    }

    private func saveAndAdvance() {
        Task {
            if isFinalEditStep {
                if await viewModel.continueCurrentStep() {
                    router.pop()
                }
            } else {
                _ = await viewModel.continueCurrentStep()
            }
        }
    }
}
