//
//  RootView.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedIntroduction") private var hasCompletedIntroduction = false
    @AppStorage("hasCompletedSetupProfile") private var hasCompletedSetupProfile = false
    @AppStorage("hasCompletedOnboarding") private var legacyHasCompletedOnboarding = false
    @Query(sort: \SetupProfileModel.updatedAt, order: .reverse)
    private var setupProfiles: [SetupProfileModel]

    var body: some View {
        appContent
    }

    private var appContent: some View {
        NavigationStack(path: $router.path) {
            Group {
                if isSetupComplete {
                    HomeRouteBuilder.build(.main)
                } else if hasCompletedIntroduction {
                    SetupProfileRouteBuilder.build(
                        .main,
                        modelContext: modelContext,
                        onComplete: completeSetupProfile,
                        onBackToIntroduction: returnToIntroduction
                    )
                } else {
                    OnboardingRouteBuilder.build(.main) {
                        router.popToRoot()
                        withAnimation(.smooth) {
                            hasCompletedIntroduction = true
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

    private var isSetupComplete: Bool {
        legacyHasCompletedOnboarding
            || hasCompletedSetupProfile
            || setupProfiles.first?.isComplete == true
    }

    private func completeSetupProfile() {
        router.popToRoot()
        withAnimation(.smooth) {
            hasCompletedSetupProfile = true
        }
    }

    private func returnToIntroduction() {
        router.popToRoot()
        withAnimation(.smooth) {
            hasCompletedIntroduction = false
        }
    }
}
