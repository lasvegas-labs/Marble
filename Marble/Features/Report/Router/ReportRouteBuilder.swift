//
//  ReportRouteBuilder.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI

struct ReportRouteBuilder {
    @ViewBuilder
    static func build(_ route: ReportRoute) -> some View {
        switch route {
        case .main:
            ReportView(viewModel: ReportViewModel())
        }
    }
}
