//
//  OrbPersonality.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import Foundation

enum OrbPersonality: String, CaseIterable, Codable, Identifiable {
    case gentle = "gentle"
    case passive = "passive"
    case aggressive = "aggressive"
    
    static var defaultValue: OrbPersonality { .gentle }
    
    var id: Self { self }

    var title: String {
        switch self {
        case .gentle: "Gentle"
        case .passive: "Passive Aggressive"
        case .aggressive: "Blunt"
        }
    }

    var index: Double {
        switch self {
        case .gentle: 0
        case .passive: 1
        case .aggressive: 2
        }
    }

    init(index: Double) {
        switch Int(index.rounded()) {
        case 0: self = .gentle
        case 1: self = .passive
        default: self = .aggressive
        }
    }
}
