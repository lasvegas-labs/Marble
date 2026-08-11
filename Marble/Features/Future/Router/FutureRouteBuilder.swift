//
//  FutureRouteBuilder.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI

struct FutureRouteBuilder {
    @ViewBuilder
    static func build(_ route: FutureRoute) -> some View {
        switch route {
        case .main:
            FuturePageView(viewModel: FutureViewModel())
        }
    }
}
