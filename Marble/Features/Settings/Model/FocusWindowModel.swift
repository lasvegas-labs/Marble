//
//  FocusWindowModel.swift
//  Marble
//

import Foundation
import SwiftData

@Model
final class FocusWindowModel {
    var id: UUID
    var name: String
    var iconSFSymbol: String
    var startMinutes: Int
    var endMinutes: Int
    var weekdays: [Int] // FocusWeekday rawValues
    
    var crossesMidnight: Bool {
        startMinutes > endMinutes
    }
    
    init(
        id: UUID = UUID(),
        name: String = "Focus Window",
        iconSFSymbol: String = "person.badge.shield.checkmark",
        startMinutes: Int = 9 * 60,
        endMinutes: Int = 17 * 60,
        weekdays: [Int] = [2, 3, 4, 5, 6] // Mon-Fri
    ) {
        self.id = id
        self.name = name
        self.iconSFSymbol = iconSFSymbol
        self.startMinutes = startMinutes
        self.endMinutes = endMinutes
        self.weekdays = weekdays
    }
}
