//
//  RootView.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: AppRouter
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeRouteBuilder.build(.main)
                .navigationDestination(
                    for: AppRoute.self,
                ) { route in
                    AppRouteBuilder.build(route)
                }
        }
        .sheet(item: $router.presentedSheet) { route in
            AppRouteBuilder.build(route)
        }
    }
}
