//
//  RGBColor.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI

struct RGBColor {
    let r: Double
    let g: Double
    let b: Double
    
    static func lerp(from: RGBColor, to: RGBColor, pct: Double) -> Color {
        let r = from.r + (to.r - from.r) * pct
        let g = from.g + (to.g - from.g) * pct
        let b = from.b + (to.b - from.b) * pct
        return Color(red: r, green: g, blue: b)
    }
}
