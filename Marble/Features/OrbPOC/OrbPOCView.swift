import SwiftUI

// MARK: - Persona Models

enum Persona: String, CaseIterable {
    case gentle = "Gentle"
    case passiveAggressive = "Passive Aggressive"
    case blunt = "Blunt"
    
    var primaryColor: Color {
        switch self {
        case .gentle: return .green
        case .passiveAggressive: return .yellow
        case .blunt: return .red
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .gentle: return .cyan // Or teal, per the blue/cyan default feel
        case .passiveAggressive: return .orange
        case .blunt: return .purple
        }
    }
}

// MARK: - POC View

public struct OrbPOCView: View {
    @State private var brightness: Double = 1.0
    @State private var animationSpeed: Double = 0.5
    @State private var selectedPersona: Persona = .gentle
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 30) {
            Text("Orb Mascot POC")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            // The Reusable OrbView component
            OrbView(
                configuration: OrbConfiguration(
                    primaryColor: selectedPersona.primaryColor,
                    secondaryColor: selectedPersona.secondaryColor,
                    brightness: brightness,
                    animationSpeed: animationSpeed
                )
            )
            .frame(width: 250, height: 250)
            // Add a subtle shadow matching the primary color to emphasize its presence
            .shadow(
                color: selectedPersona.primaryColor.opacity(0.4 * brightness),
                radius: 20 * brightness,
                x: 0,
                y: 10
            )
            
            Spacer()
            
            // Interactive Controls
            VStack(spacing: 25) {
                
                // 1. Persona/Color Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Persona (Color)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Persona", selection: $selectedPersona) {
                        ForEach(Persona.allCases, id: \.self) { persona in
                            Text(persona.rawValue).tag(persona)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 2. Brightness Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Brightness (Screen Time)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f", brightness))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $brightness, in: 0.1...1.0)
                        .tint(selectedPersona.primaryColor)
                }
                
                // 3. Animation Speed Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Animation Speed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f", animationSpeed))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $animationSpeed, in: 0.1...2.0)
                        .tint(selectedPersona.secondaryColor)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .padding(.top, 20)
        // Background to ensure the glowing blend mode looks good on both light/dark
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    OrbPOCView()
}
