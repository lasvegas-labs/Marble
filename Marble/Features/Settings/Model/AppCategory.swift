//
//  AppCategory.swift
//  Marble
//
//  Created by otnielkalit on 11/08/26.
//

import Foundation

struct DistApp: Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    var isSelected: Bool

    init(name: String, icon: String, isSelected: Bool = true) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.isSelected = isSelected
    }
}

struct AppCategory: Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    var apps: [DistApp]
    var isExpanded: Bool

    init(name: String, icon: String, apps: [DistApp], isExpanded: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.apps = apps
        self.isExpanded = isExpanded
    }

    var allSelected: Bool {
        apps.allSatisfy { $0.isSelected }
    }
}
