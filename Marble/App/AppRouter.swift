//
//  AppRouter.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import Combine
import SwiftUI

final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []

    // push screen from stack
    func push(_ route: AppRoute) {
        path.append(route)
    }

    // pop screen from stack
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    // back to the root screen
    func popToRoot() {
        path.removeLast()
    }

    // replace the last screen from stack
    func replace(with route: AppRoute) {
        path.removeLast(path.count)
        path.append(route)
    }
}
