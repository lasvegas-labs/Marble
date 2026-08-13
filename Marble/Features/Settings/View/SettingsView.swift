//
//  SettingsView.swift
//  Marble
//
//  Created by otnielkalit on 11/08/26.
//

import SwiftUI
import FamilyControls
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: SettingsViewModel
    @ObservedObject private var screenTime = ScreenTimeManager.shared
    @State private var isPickerPresented = false
    @Query private var focusWindows: [FocusWindowModel]

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.title.bold())
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                VStack(spacing: 0) {
                    SettingsRowView(icon: "person", label: "Edit your profile") {
                        router.push(.settings(.editProfile))
                    }
                    Divider().padding(.leading, 64)
                    SettingsRowView(icon: "square.3.layers.3d", label: "Edit your choosen apps") {
                        if screenTime.hasAuthorization {
                            isPickerPresented = true
                        } else {
                            screenTime.requestAuthorization()
                        }
                    }
                    Divider().padding(.leading, 64)
                    SettingsRowView(icon: "siri", label: "Choose your companion") {
                        router.push(.settings(.chooseCompanion))
                    }
                    Divider().padding(.leading, 64)
                    SettingsRowView(icon: "figure.mind.and.body.circle", label: "Edit your focus window") {
                        router.push(.settings(.focusWindows))
                    }
                    Divider().padding(.leading, 64)
                }
            }
        }
        .background(SettingsTheme.background)
        .navigationBarHidden(true)
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTime.selectionToDiscourage)
        .onAppear {
            screenTime.checkAuthorizationStatus()
        }
        .onChange(of: screenTime.selectionToDiscourage) { _ in
            let service = ScreenTimeService()
            try? service.saveSelection(screenTime.selectionToDiscourage)
            try? service.configureFocusMonitoring(for: screenTime.selectionToDiscourage, focusWindows: focusWindows)
        }
    }
}

// MARK: - Reusable Row Components

struct SettingsRowView: View {
    let icon: String
    let label: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 28)
                    .foregroundStyle(.primary)
                    .frame(width: 44)

                Text(label)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(SettingsTheme.chevron)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(SettingsTheme.cardBackground)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel())
            .environmentObject(AppRouter())
    }
}
