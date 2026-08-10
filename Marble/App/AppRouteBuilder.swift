//
//  AppRouteBuilder.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI

struct AppRouteBuilder {
    @ViewBuilder
    static func build(_ route: AppRoute) -> some View {
        switch route {
        case .home(let homeRoute):
            HomeRouteBuilder.build(homeRoute)
        }
    }
}
