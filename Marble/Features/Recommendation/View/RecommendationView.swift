import Orb
import SwiftData
import SwiftUI

struct RecommendationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @State private var showCelebration = false
    @State private var viewModel: RecommendationViewModel?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if showCelebration {
                CelebrationScreen(onBackToHome: {
                    dismiss()
                    router.dismissSheet()
                    router.popToRoot()
                })
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                if let vm = viewModel {
                    RecommendationListScreen(
                        viewModel: vm,
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showCelebration = true
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                } else {
                    ProgressView()
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .task {
            let vm = RecommendationViewModel(modelContext: modelContext)
            viewModel = vm
            await vm.load()
        }
    }
}

private struct RecommendationListScreen: View {
    @ObservedObject var viewModel: RecommendationViewModel
    let onContinue: () -> Void
    @State private var cardsAppeared = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("See Recommendations")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)

                    Text("It Could Be More Useful for You")
                        .font(.system(.subheadline))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 8)

                if viewModel.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView().scaleEffect(1.4); Spacer() }
                    Spacer()
                } else {
                    staggeredCards
                        .padding(.top, 16)
                }

                // Space for the Continue button
                Spacer(minLength: 80)
            }

            // Orb decoration — bottom left, clipped
            VStack {
                Spacer()
                HStack {
                    OrbView(configuration: OrbConfiguration(
                        backgroundColors: [.green, .mint, .teal, .cyan],
                        glowColor: .mint,
                        showShadow: false,
                        speed: 30
                    ))
                    .frame(width: 220, height: 220)
                    .offset(x: -60, y: 60)
                    Spacer()
                }
            }
            .ignoresSafeArea()

            // Continue button pinned to bottom
            VStack {
                Spacer()
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                cardsAppeared = true
            }
        }
    }

    private var staggeredCards: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 0) {
                    if index.isMultiple(of: 2) {
                        BubbleCard(
                            icon: item.iconSFSymbol,
                            title: item.message,
                            gradientColors: item.gradientColors
                        )
                        .frame(width: 200, height: 200)
                        .padding(.leading, 28)
                        .padding(.trailing, 60)
                        .opacity(cardsAppeared ? 1 : 0)
                        .offset(y: cardsAppeared ? 0 : 30)
                        .animation(
                            .spring(response: 0.55, dampingFraction: 0.72)
                            .delay(Double(index) * 0.14),
                            value: cardsAppeared
                        )

                        Spacer(minLength: 0)
                    } else {
                        Spacer(minLength: 0)

                        BubbleCard(
                            icon: item.iconSFSymbol,
                            title: item.message,
                            gradientColors: item.gradientColors
                        )
                        .frame(width: 200, height: 200)
                        .padding(.trailing, 28)
                        .padding(.leading, 60)
                        .opacity(cardsAppeared ? 1 : 0)
                        .offset(y: cardsAppeared ? 0 : 30)
                        .animation(
                            .spring(response: 0.55, dampingFraction: 0.72)
                            .delay(Double(index) * 0.14),
                            value: cardsAppeared
                        )
                    }
                }
                // Overlap cards slightly for a staggered feel
                .padding(.top, index == 0 ? 0 : -30)
            }
        }
    }
}

private struct CelebrationScreen: View {
    let onBackToHome: () -> Void
    @State private var orbAppeared = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                OrbView(configuration: OrbConfiguration(
                    backgroundColors: [.green, .mint, .teal, .cyan],
                    glowColor: .mint,
                    showShadow: true,
                    speed: 40
                ))
                .frame(width: 200, height: 200)
                .scaleEffect(orbAppeared ? 1.0 : 0.5)
                .opacity(orbAppeared ? 1 : 0)

                Text("Yay One Step Closer to Throw\nAway Doomscrolling")
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    .opacity(orbAppeared ? 1 : 0)
                    .offset(y: orbAppeared ? 0 : 20)

                Spacer()

                Button(action: onBackToHome) {
                    Text("Back to Home")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.96))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(orbAppeared ? 1 : 0)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.15)) {
                orbAppeared = true
            }
        }
    }
}

// MARK: - Bubble Card

private struct BubbleCard: View {
    let icon: String
    let title: String
    let gradientColors: [Color]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Card body
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .regular))
                    .foregroundStyle(.black.opacity(0.75))
                    .frame(height: 56)

                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 16, x: 0, y: 6)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)

            // Bubble tail — bottom center pointing down
            DownwardTail(colors: gradientColors)
                .offset(y: 19) // Push down so it sticks out of the card
        }
        .padding(.bottom, 20) // room for tail
    }
}

private struct DownwardTail: View {
    let colors: [Color]

    var body: some View {
        BubbleTailShape()
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 44, height: 20) // Wider for a smoother sweep
    }
}

private struct BubbleTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // Curve down to the rounded tip at the bottom center
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY),
            control2: CGPoint(x: rect.midX - rect.width * 0.1, y: rect.maxY)
        )
        
        // Curve back up to the top-right
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control1: CGPoint(x: rect.midX + rect.width * 0.1, y: rect.maxY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.35, y: rect.minY)
        )
        
        // Close back across the top (attaches to the card)
        path.closeSubpath()
        
        return path
    }
}

#Preview("Recommendations") {
    NavigationStack {
        RecommendationView()
            .environmentObject(AppRouter())
    }
}

