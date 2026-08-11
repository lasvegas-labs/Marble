//
//  EditAppsView.swift
//  Marble
//
//  Created by otnielkalit on 11/08/26.
//

import SwiftUI

struct EditAppsView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: EditAppsViewModel

    init(viewModel: EditAppsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            appListCard
                .padding(.horizontal, 16)

            bottomSection
        }
        .background(SettingsTheme.secondaryFill.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(SettingsTheme.iconFill)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Skip") {
                    router.pop()
                }
                .foregroundStyle(.primary)
                .font(.system(size: 17))
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Choose Your Biggest Distraction")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("This helps us personalize reminders based on your app usage.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
    }

    private var appListCard: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    allAppsRow
                    Divider()

                    ForEach(viewModel.filteredCategories) { category in
                        categoryRow(category)
                    }
                }
                .padding(.bottom, 56)
            }

            searchBar
        }
        .background(SettingsTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }

    private var allAppsRow: some View {
        Button {
            viewModel.toggleAllApps()
        } label: {
            HStack(spacing: 14) {
                selectionIndicator(isSelected: viewModel.isAllSelected)

                Image(systemName: "square.3.layers.3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .padding(8)
                    .background(SettingsTheme.iconFill)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("All Apps & Categories")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func categoryRow(_ category: AppCategory) -> some View {
        VStack(spacing: 0) {
            Button {
                viewModel.toggleExpanded(id: category.id)
            } label: {
                HStack(spacing: 14) {
                    Button {
                        viewModel.toggleCategory(id: category.id)
                    } label: {
                        selectionIndicator(isSelected: category.allSelected)
                    }
                    .buttonStyle(.plain)

                    Image(systemName: category.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(SettingsTheme.iconFill)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text(category.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: category.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(category.isExpanded ? SettingsTheme.secondaryFill : SettingsTheme.cardBackground)
            }
            .buttonStyle(.plain)

            if category.isExpanded {
                ForEach(category.apps) { app in
                    appRow(app, categoryId: category.id)
                    Divider().padding(.leading, 76)
                }
            }

            Divider()
        }
    }

    private func appRow(_ app: DistApp, categoryId: UUID) -> some View {
        Button {
            viewModel.toggleApp(categoryId: categoryId, appId: app.id)
        } label: {
            HStack(spacing: 14) {
                Spacer().frame(width: 12)

                selectionIndicator(isSelected: app.isSelected)

                Image(systemName: app.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background(SettingsTheme.iconFill)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(app.name)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(SettingsTheme.cardBackground)
        }
        .buttonStyle(.plain)
    }

    private func selectionIndicator(isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(SettingsTheme.teal)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Circle()
                    .stroke(SettingsTheme.selectionStroke, lineWidth: 1.5)
                    .frame(width: 24, height: 24)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search", text: $viewModel.searchText)
                .font(.system(size: 17))

            if viewModel.searchText.isEmpty {
                Image(systemName: "mic")
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(SettingsTheme.secondaryFill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
        .background(SettingsTheme.cardBackground)
    }

    private var bottomSection: some View {
        VStack(spacing: 14) {
            Text("\(viewModel.selectedCount) Apps Selected")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)

            Button {
                router.pop()
            } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(SettingsTheme.iconFill)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
        }
        .padding(.top, 20)
        .padding(.bottom, 32)
    }
}

#Preview {
    NavigationStack {
        EditAppsView(viewModel: EditAppsViewModel())
            .environmentObject(AppRouter())
    }
}
