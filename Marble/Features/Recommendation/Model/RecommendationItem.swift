//
//  RecommendationItem.swift
//  Marble
//
//  Created by otnielkalit on 12/08/26.
//

import SwiftUI

struct RecommendationItem: Decodable, Identifiable {
    let message: String
    let iconSFSymbol: String
    let colorName: String?
    let colorStart: String
    let colorEnd: String

    var id: String { message }

    enum CodingKeys: String, CodingKey {
        case message
        case iconSFSymbol = "icon_sf_symbol"
        case colorName = "color_name"
        case colorStart = "color_start"
        case colorEnd = "color_end"
    }

    var startColor: Color {
        Color(hex: colorStart) ?? .green
    }

    var endColor: Color {
        Color(hex: colorEnd) ?? .mint
    }

    var gradientColors: [Color] {
        [startColor, endColor]
    }
}

extension Color {
    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.hasPrefix("#") ? String(cleaned.dropFirst()) : cleaned

        guard cleaned.count == 6,
              let hexValue = UInt64(cleaned, radix: 16) else { return nil }

        let r = Double((hexValue >> 16) & 0xFF) / 255
        let g = Double((hexValue >> 8) & 0xFF) / 255
        let b = Double(hexValue & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
