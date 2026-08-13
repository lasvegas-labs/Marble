//
//  Color+Extension.swift
//  Marble
//
//  Created by Muhammad Fahmi on 13/08/26.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        guard cleaned.count == 6,
              let hexValue = UInt64(cleaned, radix: 16) else {
            return nil
        }

        self.init(
            red: CGFloat((hexValue >> 16) & 0xFF) / 255,
            green: CGFloat((hexValue >> 8) & 0xFF) / 255,
            blue: CGFloat(hexValue & 0xFF) / 255,
            alpha: 1.0
        )
    }
}
