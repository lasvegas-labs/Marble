//
//  MarbleOrb.swift
//  Marble
//

import SwiftUI
import Orb

struct MarbleOrb: View {
    var primaryColor: Color = .blue
    var secondaryColor: Color = .cyan
    var speed: CGFloat = 45

    var body: some View {
        OrbView(
            configuration: OrbConfiguration(
                backgroundColors: [primaryColor, secondaryColor, .teal],
                glowColor: primaryColor,
                showShadow: false,
                speed: speed
            )
        )
        // Add accessibility label as requested by SwiftUI best practices for mascots/images
        .accessibilityLabel("Marble Mascot Orb")
    }
}
