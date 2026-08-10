//
//  MarbleOrb.swift
//  Marble
//

import SwiftUI

struct MarbleOrb: View {
    // We can parameterize these later for persona, etc.
    var brightness: Double = 1.0
    var animationSpeed: Double = 0.5
    
    // Default blue/cyan palette as seen in the Figma POC
    var primaryColor: Color = .blue
    var secondaryColor: Color = .cyan

    var body: some View {
        OrbView(
            configuration: OrbConfiguration(
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                brightness: brightness,
                animationSpeed: animationSpeed
            )
        )
        // Add accessibility label as requested by SwiftUI best practices for mascots/images
        .accessibilityLabel("Marble Mascot Orb")
    }
}
