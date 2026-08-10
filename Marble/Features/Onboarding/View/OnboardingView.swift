//
//  OnboardingVIew.swift
//  Marble
//
//  Created by Sande Effendi on 10/08/26.
//

import Orb
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @GestureState private var isOrbPressed = false

    private let onContinue: () -> Void
    private let natureOrb = OrbConfiguration(
        backgroundColors: [.green, .mint, .teal],
        glowColor: .green,
        showShadow: false,
        speed: 45
    )

    init(
        viewModel: OnboardingViewModel,
        onContinue: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onContinue = onContinue
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let orbDiameter = width * 1.25
            let topOffset = max(
                geometry.safeAreaInsets.top,
                geometry.frame(in: .global).minY
            )

            ZStack(alignment: .top) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                orb(diameter: orbDiameter)
                    .position(
                        x: width / 2,
                        y: orbDiameter * 0.32 - topOffset - 10
                    )

                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: max(width * 0.984 - topOffset, 0))

                    pages(width: width)
                    Spacer(minLength: 24)
                    pageIndicator
                    Spacer(minLength: 24)
                    continueButton
                }
                .frame(
                    width: width,
                    height: geometry.size.height,
                    alignment: .top
                )
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .task(id: viewModel.selectedPageIndex) {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }

            withAnimation(.smooth) {
                viewModel.advance()
            }
        }
    }

    private func orb(diameter: CGFloat) -> some View {
        return OrbView(configuration: natureOrb)
            .frame(width: diameter, height: diameter)
            .overlay {
                Circle()
                    .fill(Color.green.opacity(0.32))
                    .blendMode(.multiply)
            }
            .compositingGroup()
            .scaleEffect(isOrbPressed ? 0.96 : 1)
            .brightness(isOrbPressed ? 0.08 : 0)
            .animation(.spring(duration: 0.3, bounce: 0.35), value: isOrbPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isOrbPressed) { _, isPressed, _ in
                        isPressed = true
                    }
            )
            .accessibilityHidden(true)
    }

    private func pages(width: CGFloat) -> some View {
        TabView(selection: $viewModel.selectedPageIndex) {
            ForEach(viewModel.pages) { page in
                VStack(spacing: 10) {
                    Text(page.title)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)

                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .lineLimit(3)
                }
                .padding(.horizontal, 24)
                .frame(width: width)
                .accessibilityElement(children: .combine)
                .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: width, height: 150)
    }

    private var pageIndicator: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.pages) { page in
                Circle()
                    .fill(page.id == viewModel.selectedPageIndex ? Color.primary : Color.secondary.opacity(0.45))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue("Page \(viewModel.selectedPageIndex + 1) of \(viewModel.pages.count)")
        .accessibilityAdjustableAction { direction in
            withAnimation(.smooth) {
                switch direction {
                case .increment:
                    viewModel.advance()
                case .decrement:
                    viewModel.selectedPageIndex = max(0, viewModel.selectedPageIndex - 1)
                @unknown default:
                    break
                }
            }
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        if #available(iOS 26, *) {
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
                .controlSize(.extraLarge)
                .buttonStyle(.glass)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        } else {
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
                .controlSize(.large)
                .buttonStyle(.bordered)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(), onContinue: {})
}
