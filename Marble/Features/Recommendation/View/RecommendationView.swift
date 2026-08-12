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
                VStack(alignment: .leading, spacing: 6) {
                    Text("See Recommendations")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Text("It Could Be More Useful for You")
                        .font(.system(.subheadline))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)

                if viewModel.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView().scaleEffect(1.4); Spacer() }
                    Spacer()
                } else {
                    staggeredCards
                }

                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    OrbView(configuration: OrbConfiguration(
                        backgroundColors: [.green, .mint, .teal, .cyan],
                        glowColor: .mint,
                        showShadow: false,
                        speed: 30
                    ))
                    .frame(width: 280, height: 280)
                    .offset(x: -80, y: 80)
                    Spacer()
                }
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.85))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                cardsAppeared = true
            }
        }
    }

    private var staggeredCards: some View {
        let items = viewModel.items
        return GeometryReader { geo in
            let w = geo.size.width
            let cardW: CGFloat = w * 0.45
            let cardH: CGFloat = cardW * 0.95

            VStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        if index.isMultiple(of: 2) {
                            BubbleCard(
                                icon: item.iconSFSymbol,
                                title: item.message,
                                gradientColors: item.gradientColors,
                                tailAlignment: index == items.count - 1 ? .bottomTrailing : .bottom
                            )
                            .frame(width: cardW, height: cardH)
                            .opacity(cardsAppeared ? 1 : 0)
                            .offset(y: cardsAppeared ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(Double(index) * 0.12), value: cardsAppeared)

                            Spacer()
                        } else {
                            Spacer()

                            BubbleCard(
                                icon: item.iconSFSymbol,
                                title: item.message,
                                gradientColors: item.gradientColors,
                                tailAlignment: .bottomLeading
                            )
                            .frame(width: cardW, height: cardH)
                            .opacity(cardsAppeared ? 1 : 0)
                            .offset(y: cardsAppeared ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(Double(index) * 0.12), value: cardsAppeared)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.top, 24)
        }
        .frame(minHeight: CGFloat(viewModel.items.count) * 140 + 40)
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

private struct BubbleCard: View {
    let icon: String
    let title: String
    let gradientColors: [Color]
    let tailAlignment: Alignment

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundColor(.black)

            Text(title)
                .font(.system(.caption, design: .default))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .lineLimit(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(alignment: tailAlignment) {
            BubbleTail()
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 16, height: 14)
                .offset(y: 12)
        }
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
    }
}

private struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.midY * 0.4)
        )
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
