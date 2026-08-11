//
//  SettingsView.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI
import FamilyControls

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @ObservedObject var screenTime = ScreenTimeManager.shared
    @State private var isPickerPresented = false

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            // MARK: - Screen Time / Friction Section
            Section {
                if screenTime.hasAuthorization {
                    Button {
                        isPickerPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "apps.iphone")
                                .foregroundColor(.purple)
                            Text("Select Apps to Block")
                        }
                    }
                } else {
                    Button {
                        screenTime.requestAuthorization()
                    } label: {
                        HStack {
                            Image(systemName: "hourglass")
                                .foregroundColor(.blue)
                            Text("Enable Screen Time")
                        }
                    }
                }
            } header: {
                Text("Screen Time")
            } footer: {
                Text("Choose which apps will show a friction screen when opened.")
            }
        }
        .navigationTitle("Settings")
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTime.selectionToDiscourage)
    }
}
