//
//  RootView.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if hasCompletedOnboarding {
                    HomeRouteBuilder.build(.main)
                } else {
                    OnboardingRouteBuilder.build(.main) {
                        router.popToRoot()
                        withAnimation(.smooth) {
                            hasCompletedOnboarding = true
                        }
                    }
                }
            }
                .navigationDestination(
                    for: AppRoute.self,
                ) { route in
                    AppRouteBuilder.build(route)
                }
        }
        .sheet(item: $router.presentedSheet) { route in
            AppRouteBuilder.build(route)
        }
    }
}
