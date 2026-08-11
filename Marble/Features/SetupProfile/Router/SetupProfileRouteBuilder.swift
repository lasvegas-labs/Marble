import SwiftData
import SwiftUI

struct SetupProfileRouteBuilder {
    @ViewBuilder
    static func build(
        _ route: SetupProfileRoute,
        modelContext: ModelContext,
        onComplete: @escaping () -> Void,
        onBackToIntroduction: @escaping () -> Void
    ) -> some View {
        switch route {
        case .main:
            SetupProfileView(
                viewModel: SetupProfileViewModel(
                    modelContext: modelContext,
                    screenTimeService: ScreenTimeService()
                ),
                onComplete: onComplete,
                onBackToIntroduction: onBackToIntroduction
            )
        }
    }
}
