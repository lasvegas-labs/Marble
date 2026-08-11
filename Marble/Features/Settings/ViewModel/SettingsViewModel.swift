//
//  SettingsViewModel.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isScreenTimeAccessEnabled: Bool = true
    @Published var isNotificationAccessEnabled: Bool = false
}
