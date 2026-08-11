//
//  FrictionRouteBuilder.swift
//  Marble
//

import SwiftUI

struct FrictionRouteBuilder {
    @ViewBuilder
    static func build(_ route: FrictionRoute) -> some View {
        switch route {
        case .main:
            FrictionView(viewModel: FrictionViewModel())
        }
    }
}
