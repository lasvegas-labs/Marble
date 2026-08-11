//
//  EditAppsViewModel.swift
//  Marble
//
//  Created by otnielkalit on 11/08/26.
//

import Combine
import Foundation

final class EditAppsViewModel: ObservableObject {
    @Published var categories: [AppCategory] = EditAppsViewModel.defaultCategories()
    @Published var searchText: String = ""

    var selectedCount: Int {
        categories.flatMap { $0.apps }.filter { $0.isSelected }.count
    }

    var isAllSelected: Bool {
        categories.flatMap { $0.apps }.allSatisfy { $0.isSelected }
    }

    var filteredCategories: [AppCategory] {
        guard !searchText.isEmpty else { return categories }
        return categories.compactMap { category in
            let matched = category.apps.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            guard !matched.isEmpty else { return nil }
            var copy = category
            copy.apps = matched
            copy.isExpanded = true
            return copy
        }
    }

    func toggleAllApps() {
        let newValue = !isAllSelected
        for i in categories.indices {
            for j in categories[i].apps.indices {
                categories[i].apps[j].isSelected = newValue
            }
        }
    }

    func toggleCategory(id: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == id }) else { return }
        let newValue = !categories[idx].allSelected
        for j in categories[idx].apps.indices {
            categories[idx].apps[j].isSelected = newValue
        }
    }

    func toggleExpanded(id: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == id }) else { return }
        categories[idx].isExpanded.toggle()
    }

    func toggleApp(categoryId: UUID, appId: UUID) {
        guard let catIdx = categories.firstIndex(where: { $0.id == categoryId }),
              let appIdx = categories[catIdx].apps.firstIndex(where: { $0.id == appId })
        else { return }
        categories[catIdx].apps[appIdx].isSelected.toggle()
    }

    private static func defaultCategories() -> [AppCategory] {
        [
            AppCategory(
                name: "Social",
                icon: "message.badge.filled.fill",
                apps: [
                    DistApp(name: "Discord", icon: "gamecontroller"),
                    DistApp(name: "FaceTime", icon: "video"),
                    DistApp(name: "Facebook", icon: "f.circle"),
                    DistApp(name: "Instagram", icon: "camera"),
                    DistApp(name: "LinkedIn", icon: "briefcase"),
                    DistApp(name: "WhatsApp", icon: "phone.bubble"),
                ],
                isExpanded: true
            ),
            AppCategory(
                name: "Entertainment",
                icon: "play.rectangle",
                apps: [
                    DistApp(name: "YouTube", icon: "play.circle"),
                    DistApp(name: "Netflix", icon: "tv"),
                    DistApp(name: "TikTok", icon: "music.note"),
                    DistApp(name: "Spotify", icon: "headphones"),
                ]
            ),
            AppCategory(
                name: "Games",
                icon: "gamecontroller",
                apps: [
                    DistApp(name: "Roblox", icon: "cube"),
                    DistApp(name: "PUBG Mobile", icon: "scope"),
                    DistApp(name: "Clash of Clans", icon: "shield"),
                ]
            ),
        ]
    }
}
