//
//  DynamicOrbView.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import Orb
import SwiftUI

struct DynamicOrbView: View {
    let personality: OrbPersonality
    let sliderValue: Double
    
    var amplitude: CGFloat {
        CGFloat(sliderValue / 100.0) * 18.0
    }
    
    var colors: [Color] {
        let pct = sliderValue / 100.0
        switch personality {
        case .gentle:
            let c1 = RGBColor.lerp(from: RGBColor(r: 0.2, g: 0.8, b: 0.2), to: RGBColor(r: 0.04, g: 0.15, b: 0.08), pct: pct)
            let c2 = RGBColor.lerp(from: RGBColor(r: 0.0, g: 0.9, b: 0.6), to: RGBColor(r: 0.02, g: 0.12, b: 0.1), pct: pct)
            let c3 = RGBColor.lerp(from: RGBColor(r: 0.1, g: 0.6, b: 0.6), to: RGBColor(r: 0.02, g: 0.1, b: 0.1), pct: pct)
            return [c1, c2, c3]
        case .passive:
            let c1 = RGBColor.lerp(from: RGBColor(r: 0.9, g: 0.1, b: 0.1), to: RGBColor(r: 0.22, g: 0.03, b: 0.03), pct: pct)
            let c2 = RGBColor.lerp(from: RGBColor(r: 1.0, g: 0.5, b: 0.0), to: RGBColor(r: 0.18, g: 0.06, b: 0.01), pct: pct)
            let c3 = RGBColor.lerp(from: RGBColor(r: 1.0, g: 0.8, b: 0.1), to: RGBColor(r: 0.14, g: 0.09, b: 0.01), pct: pct)
            return [c1, c2, c3]
        case .aggressive:
            let c1 = RGBColor.lerp(from: RGBColor(r: 1.0, g: 0.5, b: 0.0), to: RGBColor(r: 0.18, g: 0.06, b: 0.02), pct: pct)
            let c2 = RGBColor.lerp(from: RGBColor(r: 0.9, g: 0.1, b: 0.1), to: RGBColor(r: 0.15, g: 0.02, b: 0.04), pct: pct)
            let c3 = RGBColor.lerp(from: RGBColor(r: 1.0, g: 0.2, b: 0.5), to: RGBColor(r: 0.12, g: 0.01, b: 0.12), pct: pct)
            return [c1, c2, c3]
        }
    }
    
    var glowColor: Color {
        switch personality {
        case .gentle: return .green
        case .passive: return .orange
        case .aggressive: return .red
        }
    }
    
    var baseSpeed: Double {
        switch personality {
        case .gentle: return 45
        case .passive: return 80
        case .aggressive: return 60
        }
    }
    
    var orbConfig: OrbConfiguration {
        let pct = sliderValue / 100.0
        return OrbConfiguration(
            backgroundColors: colors,
            glowColor: glowColor,
            coreGlowIntensity: (1.0 - pct) * 1.2,
            showBackground: true,
            showWavyBlobs: sliderValue < 98,
            showParticles: sliderValue < 95,
            showGlowEffects: sliderValue < 95,
            showShadow: sliderValue < 95,
            speed: baseSpeed * (1.0 - pct)
        )
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let phase = CGFloat(time * 2.2)
            
            OrbView(configuration: orbConfig)
                .mask {
                    WobblyBlobShape(amplitude: amplitude, phase: phase)
                }
        }
    }
}
