//
//  HomeRouteBuilder.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI

struct HomeRouteBuilder {
    @ViewBuilder
    static func build(_ route: HomeRoute) -> some View {

        switch route {
        // main home view
        case .main:
            HomeView(viewModel: HomeViewModel())

        // daftarkan home view route lainnya disini
        }

    }
}
