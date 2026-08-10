//
//  AppRoute.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import Foundation

enum AppRoute: Hashable, Identifiable {
    case home(HomeRoute)
    case friction(FrictionRoute)
    case recommendation // Placeholder for now

    var id: Self { self }
}
