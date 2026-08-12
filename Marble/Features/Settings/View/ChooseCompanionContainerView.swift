import SwiftData
import SwiftUI

struct ChooseCompanionContainerView: View {
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
                OrbPersonaStepView(viewModel: viewModel)
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
            "Choose Companion",
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
        .onAppear {
            viewModel.resetToCompanionStep()
        }
    }

    private var navigationHeader: some View {
        HStack(spacing: 12) {
            Button(action: { router.pop() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 42, height: 42)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Spacer()

            Text("Choose Companion")
                .font(.headline)

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
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
        Button(action: saveAction) {
            HStack(spacing: 8) {
                if viewModel.isWorking {
                    ProgressView()
                }
                Text("Save Companion")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(viewModel.isWorking)
        .controlSize(.extraLarge)
    }

    private func saveAction() {
        Task {
            if await viewModel.continueCurrentStep() {
                router.pop()
            }
        }
    }
}
