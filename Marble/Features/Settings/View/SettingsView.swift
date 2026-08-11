//
//  SettingsView.swift
//  Marble
//
//  Created by otnielkalit on 11/08/26.
//

import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: SettingsViewModel
    @ObservedObject private var screenTime = ScreenTimeManager.shared
    @State private var isPickerPresented = false

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                VStack(spacing: 0) {
                    settingsNavRow(icon: "person", label: "Edit your profile")
                    Divider().padding(.leading, 64)
                    settingsNavRow(icon: "square.3.layers.3d", label: "Edit your choosen apps") {
                        if screenTime.hasAuthorization {
                            isPickerPresented = true
                        } else {
                            screenTime.requestAuthorization()
                        }
                    }
                    Divider().padding(.leading, 64)
                    settingsNavRow(icon: "siri", label: "Choose your companion")
                    Divider().padding(.leading, 64)
                    settingsNavRow(icon: "figure.mind.and.body.circle", label: "Edit your focus window")
                    Divider().padding(.leading, 64)
                    settingsToggleRow(
                        icon: "app.badge.clock",
                        label: "Screen Time Access",
                        isOn: $viewModel.isScreenTimeAccessEnabled
                    )
                    Divider().padding(.leading, 64)
                    settingsToggleRow(
                        icon: "bell",
                        label: "Notification Access",
                        isOn: $viewModel.isNotificationAccessEnabled
                    )
                    Divider().padding(.leading, 64)
                }
            }
        }
        .background(SettingsTheme.background)
        .navigationBarHidden(true)
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTime.selectionToDiscourage)
    }

    private func settingsNavRow(icon: String, label: String, action: @escaping () -> Void = {}) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 28)
                    .foregroundStyle(.primary)
                    .frame(width: 44)

                Text(label)
                    .font(.system(size: 17))
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(SettingsTheme.chevron)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(SettingsTheme.cardBackground)
        }
        .buttonStyle(.plain)
    }

    private func settingsToggleRow(
        icon: String,
        label: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 28)
                .foregroundStyle(.primary)
                .frame(width: 44)

            Text(label)
                .font(.system(size: 17))
                .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(SettingsTheme.teal)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(SettingsTheme.cardBackground)
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel())
            .environmentObject(AppRouter())
    }
}
