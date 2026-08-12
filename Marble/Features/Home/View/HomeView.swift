//
//  HomeView.swift
//  Marble
//f
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI
import FamilyControls

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: HomeViewModel
    @AppStorage("hasCompletedPersonalization_v3") private var hasCompletedPersonalization = false

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // Tab 0: Home Content
            Group {
                if hasCompletedPersonalization {
                    homeTabContent
                } else {
                    emptyStateContent
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)

            // Tab 1: Report Content
            ReportRouteBuilder.build(.main)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Report")
                }
                .tag(1)

            // Tab 2: Settings Content
            SettingsRouteBuilder.build(.main, modelContext: modelContext)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .onAppear {
            viewModel.loadOrbPersonality()
        }
    }

    private var homeTabContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Title
            HStack {
                Text("Home")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)

            Spacer()

            // 1. Center: Dynamic Orb Mascot (Resized to 320x320)
            HStack {
                Spacer()
                DynamicOrbView(
                    personality: viewModel.orbPersonality,
                    sliderValue: viewModel.glowSliderValue
                )
                .frame(width: 320, height: 320)
                Spacer()
            }

            Spacer()

            // 2. Testing Slider Panel
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "sun.min")
                        .foregroundColor(.secondary)
                    Slider(
                        value: $viewModel.glowSliderValue,
                        in: 0...100,
                        onEditingChanged: { _ in
                            viewModel.saveGlowSliderValue(viewModel.glowSliderValue)
                        }
                    )
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.orange)
                }

                HStack {
                    Text("Orb State: \(Int(viewModel.glowSliderValue))%")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)

            // 3. Clickable Screen Time Overview Card
            Button(action: {
                router.push(.future(.main))
            }) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today Screen Time")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Color(uiColor: .systemGray))

                        Text("3h 17m")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("See what happen in the future, if you do this constantly.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(uiColor: .systemGray3))
                        .font(.system(.title3, weight: .semibold))
                }
                .padding(.vertical, 10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }

    private var emptyStateContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Center: Dynamic Orb Mascot (Resized to 270x270 for empty state)
            HStack {
                Spacer()
                DynamicOrbView(
                    personality: viewModel.orbPersonality,
                    sliderValue: viewModel.glowSliderValue
                )
                .frame(width: 270, height: 270)
                Spacer()
            }

            Spacer()

            // Empty State Text Stack
            VStack(spacing: 8) {
                Text("No Datas")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Please complete your personalization details.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 24)

            Spacer()

            // Start Button
            Button(action: {
                withAnimation(.smooth) {
                    hasCompletedPersonalization = true
                }
            }) {
                Text("Start")
                    .font(.system(.body, design: .rounded).bold())
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color(uiColor: .systemBackground))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.black.opacity(0.04), lineWidth: 1.0)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}
