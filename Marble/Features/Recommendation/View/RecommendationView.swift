import Orb
import SwiftUI

// MARK: - Main Recommendation View (2-screen flow)

struct RecommendationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter
    @State private var showCelebration = false

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
                RecommendationListScreen(onContinue: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showCelebration = true
                    }
                })
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
    }
}

// MARK: - Screen 1: Recommendation List

private struct RecommendationListScreen: View {
    let onContinue: () -> Void

    // Card entrance animation
    @State private var cardsAppeared = false

    var body: some View {
        ZStack {
            // Background
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("See Recommendations")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.black)

                    Text("It Could Be More Useful for You")
                        .font(.system(.subheadline, design: .default))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)

                // Staggered Bubble Cards
                ZStack {
                    // Card 1: Read book (top-left)
                    BubbleCard(
                        icon: "text.book.closed.fill",
                        title: "Read book to\nactivate your left brain",
                        gradientColors: [
                            Color(red: 0.85, green: 0.97, blue: 0.82),
                            Color(red: 0.78, green: 0.95, blue: 0.72)
                        ],
                        tailAlignment: .bottom
                    )
                    .frame(width: 155, height: 145)
                    .offset(x: -75, y: -130)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 30)

                    // Card 2: Quick sightseeing (right)
                    BubbleCard(
                        icon: "figure.walk",
                        title: "Quick sightseeing around\nyour place to\nfreshen you eye",
                        gradientColors: [
                            Color(red: 0.82, green: 0.91, blue: 1.0),
                            Color(red: 0.75, green: 0.87, blue: 0.98)
                        ],
                        tailAlignment: .bottomLeading
                    )
                    .frame(width: 160, height: 150)
                    .offset(x: 65, y: -30)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 30)

                    // Card 3: Play piano (left)
                    BubbleCard(
                        icon: "music.note",
                        title: "Play piano",
                        gradientColors: [
                            Color(red: 0.92, green: 0.80, blue: 0.98),
                            Color(red: 0.88, green: 0.75, blue: 0.95)
                        ],
                        tailAlignment: .bottom
                    )
                    .frame(width: 130, height: 130)
                    .offset(x: -85, y: 70)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 30)

                    // Card 4: Stretching (right)
                    BubbleCard(
                        icon: "figure.flexibility",
                        title: "Stretching to\nstrengthen your bones",
                        gradientColors: [
                            Color(red: 1.0, green: 0.96, blue: 0.82),
                            Color(red: 0.98, green: 0.93, blue: 0.75)
                        ],
                        tailAlignment: .bottomLeading
                    )
                    .frame(width: 155, height: 150)
                    .offset(x: 50, y: 180)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 30)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                .padding(.top, 16)

                Spacer()
            }

            // Orb peeking from bottom-left
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

            // Bottom Continue button
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
}

// MARK: - Screen 2: Celebration

private struct CelebrationScreen: View {
    let onBackToHome: () -> Void

    @State private var orbAppeared = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Centered Orb
                OrbView(configuration: OrbConfiguration(
                    backgroundColors: [.green, .mint, .teal, .cyan],
                    glowColor: .mint,
                    showShadow: true,
                    speed: 40
                ))
                .frame(width: 200, height: 200)
                .scaleEffect(orbAppeared ? 1.0 : 0.5)
                .opacity(orbAppeared ? 1 : 0)

                // Celebration text
                Text("Yay One Step Closer to Throw\nAway Doomscrolling")
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    .opacity(orbAppeared ? 1 : 0)
                    .offset(y: orbAppeared ? 0 : 20)

                Spacer()

                // Back to Home button
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

// MARK: - Speech Bubble Card

private struct BubbleCard: View {
    let icon: String
    let title: String
    let gradientColors: [Color]
    let tailAlignment: Alignment

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(.black)

            Text(title)
                .font(.system(.caption, design: .default))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .lineLimit(3)
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
            // Speech bubble tail
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
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Bubble Tail Shape

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

// MARK: - Preview

#Preview("Recommendations") {
    NavigationStack {
        RecommendationView()
            .environmentObject(AppRouter())
    }
}
