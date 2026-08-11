//
//  OnboardingRouteBuilder.swift
//  Marble
//
//  Created by Sande Effendi on 10/08/26.
//

import SwiftUI

struct OnboardingRouteBuilder {
    @ViewBuilder
    static func build(
        _ route: OnboardingRoute,
        onContinue: @escaping () -> Void
    ) -> some View {
        switch route {
        case .main:
            OnboardingView(
                viewModel: OnboardingViewModel(),
                onContinue: onContinue
            )
        }
    }
}
