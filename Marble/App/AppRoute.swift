//
//  AppRoute.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import Foundation

enum AppRoute: Hashable, Identifiable {
    case home(HomeRoute)

    var id: Self { self }
}
