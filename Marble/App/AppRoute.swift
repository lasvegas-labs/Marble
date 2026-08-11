//
//  AppRoute.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import Foundation

enum AppRoute: Hashable, Identifiable {
    case home(HomeRoute)
    case report(ReportRoute)
    case settings(SettingsRoute)
    case future(FutureRoute)
    case friction(FrictionRoute)
    case recommendation

    var id: Self { self }
}
