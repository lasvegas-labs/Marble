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
        appContent
    }

    private var appContent: some View {
        TabView {
            // Home tab
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
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            // Report tab
            NavigationStack {
                ReportRouteBuilder.build(.main)
            }
            .tabItem {
                Label("Report", systemImage: "chart.bar.fill")
            }
        }
        .sheet(item: $router.presentedSheet) { route in
            AppRouteBuilder.build(route)
        }
    }
}
