//
//  SettingsRouteBuilder.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI

struct SettingsRouteBuilder {
    @ViewBuilder
    static func build(_ route: SettingsRoute) -> some View {
        switch route {
        case .main:
            SettingsView(viewModel: SettingsViewModel())
        case .editApps:
            EditAppsView(viewModel: EditAppsViewModel())
        }
    }
}
