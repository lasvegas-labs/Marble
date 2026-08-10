import SwiftUI

public struct OrbView: View {
    public var configuration: OrbConfiguration
    
    public init(configuration: OrbConfiguration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            
            TimelineView(.animation(minimumInterval: 1 / 60)) { timeline in
                // Time tracking based on the animation speed
                let now = timeline.date.timeIntervalSinceReferenceDate * configuration.animationSpeed
                
                ZStack {
                    // 1. Base gradient background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    configuration.primaryColor.opacity(0.8),
                                    configuration.secondaryColor.opacity(0.6)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: size / 2
                            )
                        )
                    
                    // 2. Secondary color blob for fluid mixing
                    Blob(color: configuration.secondaryColor,
                         size: size,
                         offset: CGPoint(x: cos(now * 0.7) * size * 0.25, y: sin(now * 0.8) * size * 0.25),
                         scale: 0.8 + sin(now * 1.1) * 0.2,
                         rotation: now * 30)
                        
                    // 3. Primary color blob moving in an opposing path
                    Blob(color: configuration.primaryColor,
                         size: size,
                         offset: CGPoint(x: -sin(now * 1.2) * size * 0.2, y: -cos(now * 0.9) * size * 0.2),
                         scale: 0.9 + cos(now * 1.3) * 0.3,
                         rotation: -now * 45)
                         
                    // 4. A brighter/white subtle light area moving organically
                    Blob(color: .white.opacity(0.6),
                         size: size,
                         offset: CGPoint(x: cos(now * 1.5) * size * 0.15, y: -sin(now * 1.4) * size * 0.2),
                         scale: 0.6 + sin(now * 0.8) * 0.2,
                         rotation: now * 60)
                }
                // Massive blur to blend the blobs perfectly and eliminate hard edges
                .blur(radius: size * 0.15)
                // Scale up slightly so the blurred edge isn't transparent before clipping
                .scaleEffect(1.2)
                // The perfect circular orb container
                .clipShape(Circle())
            }
            .frame(width: size, height: size)
            // Center the TimelineView inside the GeometryReader
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        
        // Handle Brightness mapping:
        // We use brightness modifier for dimming effect, and opacity for extreme low end
        .brightness((configuration.brightness - 1.0) * 0.5) // Ranges from -0.45 to 0.0
        .opacity(0.3 + (0.7 * configuration.brightness)) // Prevents complete invisibility
    }
}

fileprivate struct Blob: View {
    var color: Color
    var size: CGFloat
    var offset: CGPoint
    var scale: Double
    var rotation: Double
    
    var body: some View {
        Ellipse()
            .fill(color)
            // Giving the blob an oval shape for more organic stretching during rotation
            .frame(width: size * 0.8, height: size * 1.2)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: offset.x, y: offset.y)
            .blendMode(.screen) // Creates the glowing, soft additive light effect
    }
}
