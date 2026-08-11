//
//  GradeLevel.swift
//
//  Created by Marble on 11/08/26.
//

import Foundation

enum GradeLevel: String, CaseIterable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"

    var range: String {
        switch self {
        case .a: "≤ 20 hours/week"
        case .b: "21–30 hours/week"
        case .c: "31–40 hours/week"
        case .d: "> 40 hours/week"
        }
    }

    static func grade(for hours: Double) -> GradeLevel {
        switch hours {
        case ...20: .a
        case 21...30: .b
        case 31...40: .c
        default: .d
        }
    }
}
