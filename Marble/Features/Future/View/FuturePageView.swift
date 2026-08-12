import SwiftUI

struct FuturePageView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FutureViewModel
    @State private var currentIndex: Int = 1
    @State private var dragOffset: CGFloat = 0

    init(viewModel: FutureViewModel = FutureViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)
            
            // Main Content Stack raised to the top
            VStack(spacing: 24) {
                // Header Text block
                VStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.bottom, 8)
                    } else {
                        Text(viewModel.impactData != nil ? "\(viewModel.impactData!.totalHours)h" : "...")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .foregroundColor(.primary)
                    }
                    
                    (Text("If You Keep ")
                        .foregroundColor(.secondary)
                     + Text("This Up")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                     + Text(" for the Next ")
                        .foregroundColor(.secondary)
                     + Text(viewModel.impactData != nil ? "\(viewModel.impactData!.projectionYears) Years" : "...")
                        .fontWeight(.bold)
                        .foregroundColor(.primary))
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    
                    Text("that's...")
                        .font(.system(.title3, design: .rounded))
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                
                // Swipeable Card Carousel
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        cardContainer(index: index)
                    }
                }
                .frame(height: 410)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.width
                            if currentIndex == 0 && translation > 0 {
                                dragOffset = translation / 3
                            } else if currentIndex == 2 && translation < 0 {
                                dragOffset = translation / 3
                            } else {
                                dragOffset = translation
                            }
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 70
                            var newIndex = currentIndex
                            if value.predictedEndTranslation.width < -threshold {
                                newIndex = min(currentIndex + 1, 2)
                            } else if value.predictedEndTranslation.width > threshold {
                                newIndex = max(currentIndex - 1, 0)
                            }
                            
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.82, blendDuration: 0)) {
                                currentIndex = newIndex
                                dragOffset = 0
                            }
                        }
                )
                
                // Bottom indicator text
                (Text("See What ")
                    .foregroundColor(.primary)
                 + Text("You’ll Lose")
                    .fontWeight(.bold)
                    .foregroundColor(.primary))
                .font(.system(.title2, design: .rounded))
                .padding(.top, 8)
            }
            
            Spacer(minLength: 90) // Push everything upwards moderately
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .onAppear {
            viewModel.loadOrbPersonality()
            Task {
                await viewModel.loadImpactData(modelContext: modelContext)
            }
        }
    }
    
    private func cardView(index: Int) -> some View {
        let title: String
        let iconName: String
        let subtitle: String
        let description: String
        
        if let data = viewModel.impactData, data.categories.count > index {
            let cat = data.categories[index]
            title = "\(data.totalHours) H - \(data.totalDays) D"
            iconName = cat.iconSFSymbol
            subtitle = cat.category.uppercased()
            description = cat.message
        } else {
            title = "..."
            iconName = "hourglass"
            subtitle = "LOADING..."
            description = "Fetching your future impact projections..."
        }
        
        return VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("your time lost")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: iconName)
                .font(.system(size: 72)) // Sedikit diperkecil agar teks bisa lebih besar
                .foregroundColor(.primary)
                .padding(.vertical, 4)
            
            VStack(spacing: 8) {
                Text(subtitle)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(.body, design: .rounded)) // Font diperbesar ke body
                    .fontWeight(.medium)
                    .foregroundColor(.primary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(6) // Line limit ditambah
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.vertical, 24) // Padding diperkecil agar konten bisa bernafas
        .padding(.horizontal, 24)
        .frame(width: 275, height: 385)
        .background(
            ZStack {
                // Glass Base Layer
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                viewModel.personaColor.opacity(0.28), // Soft theme color bleed at top
                                Color(uiColor: .systemBackground).opacity(0.75) // Glassy white base at bottom
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Specular Glass Edge Highlight (creates 3D thickness)
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.60),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.0
                    )
                    .offset(y: 0.8)
                    .mask(RoundedRectangle(cornerRadius: 28))
            }
        )
        .overlay(
            // Thin elegant outline
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            viewModel.personaColor.opacity(0.55), // Fine outline at the top curve
                            Color.white.opacity(0.20)            // Fades to soft glassy white border at bottom
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.2 // Thinner outline as requested
                )
        )
    }
    
    private func cardContainer(index: Int) -> some View {
        let distance = CGFloat(index - currentIndex) + (dragOffset / 295)
        let scale = 1.0 - min(abs(distance) * 0.12, 0.15)
        let xOffset = distance * 215
        let opacity = 1.0 - min(abs(distance) * 0.5, 0.6)
        let zIndex = 5.0 - abs(distance)
        let rotationAngle = Double(distance) * 5.0
        
        return ZStack {
            // Soft premium glow behind the card (gradient halo effect)
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            viewModel.personaColor.opacity(0.55),
                            viewModel.personaColor.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 265, height: 375)
                .blur(radius: 35)
                .opacity(1.0 - min(abs(distance) * 0.8, 1.0))
                
            cardView(index: index)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4) // Grounding physical shadow
                .shadow(color: viewModel.personaColor.opacity(0.18), radius: 25, x: 0, y: 12) // Colored glow shadow
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotationAngle))
        .offset(x: xOffset)
        .opacity(opacity)
        .zIndex(zIndex)
    }
}
