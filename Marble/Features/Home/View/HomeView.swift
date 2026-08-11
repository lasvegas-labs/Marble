//
//  HomeView.swift
//  Marble
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI
import FamilyControls

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // Tab 0: Home Content
            homeTabContent
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
            SettingsRouteBuilder.build(.main)
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
        VStack(spacing: 0) {
            Spacer()

            // 1. Center: Dynamic Orb Mascot
            DynamicOrbView(
                personality: viewModel.orbPersonality,
                sliderValue: viewModel.glowSliderValue
            )
            .frame(width: 220, height: 220)
            .padding(.vertical, 10)

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
            .padding(.bottom, 25)

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
                            .foregroundColor(Color(uiColor: .systemGray))
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
            .padding(.bottom, 20)
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}
