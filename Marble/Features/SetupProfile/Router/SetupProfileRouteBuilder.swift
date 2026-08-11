//
//  SetupProfileRouteBuilder.swift
//  Marble
//
//  Created by Sande Effendi on 11/08/26.
//

import SwiftUI

struct SetupProfileRouteBuilder {
    @ViewBuilder
    static func build(_ route: SetupProfileRoute) -> some View {
        switch route {
        case .main:
            SetupProfileView(viewModel: SetupProfileViewModel())
        }
    }
}
