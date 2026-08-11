import Combine
import Foundation
import SwiftUI

final class FutureViewModel: ObservableObject {
    static let orbPersonalityKey = "orbPersonality"
    
    @Published var orbPersonality: OrbPersonality = .defaultValue

    init() {
        loadOrbPersonality()
    }

    func loadOrbPersonality() {
        let savedValue = UserDefaults.standard.string(forKey: Self.orbPersonalityKey) ?? ""
        self.orbPersonality = OrbPersonality(rawValue: savedValue) ?? .defaultValue
    }

    var personaColor: Color {
        switch orbPersonality {
        case .gentle:
            return Color(red: 0.0, green: 0.85, blue: 0.60)
        case .passive:
            return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .aggressive:
            return Color(red: 1.0, green: 0.25, blue: 0.25)
        }
    }
}
