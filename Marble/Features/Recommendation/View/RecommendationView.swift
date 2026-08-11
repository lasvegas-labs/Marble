import SwiftUI

struct RecommendationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding()
                            .background(Circle().fill(Color(white: 0.95)))
                    }
                    .padding()
                }
                
                VStack(spacing: 4) {
                    Text("See Recommendation")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("It Could Be More Useful for You")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Floating boxes (mocking the UI based on screenshot)
            VStack {
                Spacer().frame(height: 150)
                
                HStack {
                    RecommendationCard(
                        icon: "book.fill",
                        text: "Read book to activate your left brain",
                        bgColor: Color.green.opacity(0.2)
                    )
                    .offset(x: -20, y: 0)
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    RecommendationCard(
                        icon: "figure.walk",
                        text: "Quick sightseeing your place to freshen up",
                        bgColor: Color.blue.opacity(0.2)
                    )
                    .offset(x: 20, y: -40)
                }
                
                HStack {
                    RecommendationCard(
                        icon: "music.note",
                        text: "Play piano",
                        bgColor: Color.purple.opacity(0.2)
                    )
                    .offset(x: -40, y: -20)
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    RecommendationCard(
                        icon: "figure.mind.and.body",
                        text: "Stretching to strengthen your body",
                        bgColor: Color.yellow.opacity(0.2)
                    )
                    .offset(x: 20, y: -20)
                }
                Spacer()
            }
            .padding(.horizontal, 40)
            
            // Orb Background at bottom
            VStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0/255, green: 255/255, blue: 200/255), Color(red: 0/255, green: 200/255, blue: 255/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(x: -80, y: 150)
                        .blur(radius: 10)
                    
                    Button("Continue") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }
}

struct RecommendationCard: View {
    var icon: String
    var text: String
    var bgColor: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .padding(.bottom, 4)
            Text(text)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 140, height: 140)
        .background(bgColor)
        .cornerRadius(16)
        // Add speech bubble tail (simplified)
        .overlay(
            Triangle()
                .fill(bgColor)
                .frame(width: 20, height: 20)
                .offset(y: 80)
            , alignment: .bottom
        )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
