//
//  AppRouter.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import Combine
import Foundation

extension Notification.Name {
    static let openRecommendation = Notification.Name("MarbleOpenRecommendation")
}

final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var presentedSheet: AppRoute?

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func replace(with route: AppRoute) {
        guard !path.isEmpty else {
            push(route)
            return
        }

        path[path.endIndex - 1] = route
    }

    func presentSheet(_ route: AppRoute) {
        presentedSheet = route
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func navigateToRecommendation() {
        // Reset shield state to friction for future shield triggers
        UserDefaults(suiteName: "group.com.lasvegas.Marblefahmi1")?.set("friction", forKey: "marble_shield_state")

        // Dismiss any presented sheet first
        presentedSheet = nil
        // Push recommendation screen if not already visible
        if path.last != .recommendation {
            push(.recommendation)
        }
    }
}
