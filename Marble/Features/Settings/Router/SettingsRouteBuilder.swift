//
//  SettingsRouteBuilder.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftData
import SwiftUI

struct SettingsRouteBuilder {
    @ViewBuilder
    static func build(_ route: SettingsRoute, modelContext: ModelContext) -> some View {
        switch route {
        case .main:
            SettingsView(viewModel: SettingsViewModel())
        case .editProfile:
            EditProfileContainerView(modelContext: modelContext)
        case .chooseCompanion:
            ChooseCompanionContainerView(modelContext: modelContext)
        case .focusWindows:
            FocusWindowContainerView(modelContext: modelContext)
        }
    }
}
