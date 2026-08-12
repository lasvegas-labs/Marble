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
        case .report(let reportRoute):
            ReportRouteBuilder.build(reportRoute)
        case .settings(let settingsRoute):
            SettingsRouteBuilderWrapper(settingsRoute: settingsRoute)
        case .future(let futureRoute):
            FutureRouteBuilder.build(futureRoute)
        case .friction(let frictionRoute):
            FrictionRouteBuilder.build(frictionRoute)
        case .recommendation:
            RecommendationView()
        }
    }
}

private struct SettingsRouteBuilderWrapper: View {
    let settingsRoute: SettingsRoute
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        SettingsRouteBuilder.build(settingsRoute, modelContext: modelContext)
    }
}
