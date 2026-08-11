//
//  OrbPersonality.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import Foundation

enum OrbPersonality: String, CaseIterable {
    case gentle = "gentle"
    case passive = "passive"
    case aggressive = "aggressive"
    
    static var defaultValue: OrbPersonality { .gentle }
}
