//
//  FocusWindowContainerView.swift
//  Marble
//

import SwiftData
import SwiftUI

struct FocusWindowContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @Query private var focusWindows: [FocusWindowModel]
    @Query private var setupProfiles: [SetupProfileModel]
    
    @State private var selectedWindow: FocusWindowModel?
    
    init(modelContext: ModelContext) {
        // Initial setup if needed
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(uiColor: .systemBackground), in: Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
                
                Spacer()
                
                Text("Focus Window")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    // Create new empty focus window for editing
                    let newWindow = FocusWindowModel(
                        name: "Focus Window \(String(format: "%03d", focusWindows.count + 1))",
                        startMinutes: 9 * 60,
                        endMinutes: 17 * 60,
                        weekdays: [2, 3, 4, 5, 6] // Mon-Fri
                    )
                    selectedWindow = newWindow
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(uiColor: .systemBackground), in: Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Content
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(focusWindows) { window in
                        FocusWindowCard(window: window)
                            .onTapGesture {
                                selectedWindow = window
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .navigationBarHidden(true)
        .onAppear {
            migrateInitialFocusWindowIfNeeded()
        }
        .sheet(item: $selectedWindow) { window in
            FocusWindowEditSheet(
                window: window,
                isNew: !focusWindows.contains(where: { $0.id == window.id }),
                onSave: { updatedWindow in
                    if !focusWindows.contains(where: { $0.id == updatedWindow.id }) {
                        modelContext.insert(updatedWindow)
                    }
                    try? modelContext.save()
                    syncSchedules(adding: updatedWindow)
                    selectedWindow = nil
                },
                onDelete: {
                    modelContext.delete(window)
                    try? modelContext.save()
                    syncSchedules(removing: window)
                    selectedWindow = nil
                }
            )
            .presentationDetents([.fraction(0.85), .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func migrateInitialFocusWindowIfNeeded() {
        if focusWindows.isEmpty, let profile = setupProfiles.first {
            if let start = profile.focusStartMinutes,
               let end = profile.focusEndMinutes,
               !profile.focusWeekdays.isEmpty {
                
                let initialWindow = FocusWindowModel(
                    name: "Work Time",
                    startMinutes: start,
                    endMinutes: end,
                    weekdays: profile.focusWeekdays
                )
                modelContext.insert(initialWindow)
                try? modelContext.save()
                syncSchedules(adding: initialWindow)
            }
        }
    }
    
    private func syncSchedules(adding newWindow: FocusWindowModel? = nil, removing deletedWindow: FocusWindowModel? = nil) {
        var currentWindows = focusWindows
        if let newWindow = newWindow, !currentWindows.contains(where: { $0.id == newWindow.id }) {
            currentWindows.append(newWindow)
        }
        if let deletedWindow = deletedWindow {
            currentWindows.removeAll { $0.id == deletedWindow.id }
        }
        
        let service = ScreenTimeService()
        let selection = service.loadSelection()
        try? service.configureFocusMonitoring(for: selection, focusWindows: currentWindows)
    }
}

struct FocusWindowCard: View {
    let window: FocusWindowModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: window.iconSFSymbol)
                .font(.title2)
                .foregroundColor(.primary)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(window.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(timeString(from: window.startMinutes) + " - " + timeString(from: window.endMinutes))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    private func timeString(from minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return String(format: "%02d.%02d", hours, mins)
    }
}
