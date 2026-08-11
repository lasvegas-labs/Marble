//
//  HomeViewModel.swift
//  Marble
//
//  Created by Sande Effendi on 03/08/26.
//

import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    /// Configurable storage key for Orb personality saved by the Onboarding team
    static let orbPersonalityKey = "orbPersonality"
    
    @Published var selectedTab: Int = 0
    @Published var orbPersonality: OrbPersonality = .defaultValue
    @Published var glowSliderValue: Double = 0.0

    init() {
        loadOrbPersonality()
        loadGlowSliderValue()
    }

    func loadOrbPersonality() {
        let savedValue = UserDefaults.standard.string(forKey: Self.orbPersonalityKey) ?? ""
        self.orbPersonality = OrbPersonality(rawValue: savedValue) ?? .defaultValue
    }

    func loadGlowSliderValue() {
        if UserDefaults.standard.object(forKey: "glowSliderValue") != nil {
            self.glowSliderValue = UserDefaults.standard.double(forKey: "glowSliderValue")
        } else {
            self.glowSliderValue = 0.0
        }
    }

    func saveGlowSliderValue(_ newValue: Double) {
        self.glowSliderValue = newValue
        UserDefaults.standard.set(newValue, forKey: "glowSliderValue")
    }
}
