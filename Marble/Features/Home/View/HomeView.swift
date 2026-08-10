//
//  HomeView.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI
import FamilyControls

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject var screenTime = ScreenTimeManager.shared
    @State private var isPickerPresented = false

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Ini adalah homescreen")

            Button("Print Hello World!", action: viewModel.printGreeting)
                .buttonStyle(.borderedProminent)
            
            Button("Show Friction Screen") {
                router.push(.friction(.main))
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            if screenTime.hasAuthorization {
                Button("Select Apps to Block") {
                    isPickerPresented = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
            } else {
                Button("Enable Screen Time") {
                    screenTime.requestAuthorization()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTime.selectionToDiscourage)
    }
}
