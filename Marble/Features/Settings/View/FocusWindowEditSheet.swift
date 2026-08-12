//
//  FocusWindowEditSheet.swift
//  Marble
//

import SwiftUI

struct FocusWindowEditSheet: View {
    let window: FocusWindowModel
    let isNew: Bool
    let onSave: (FocusWindowModel) -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var startMinutes: Int
    @State private var endMinutes: Int
    @State private var weekdays: [Int]
    
    @State private var isEditingName = false
    @FocusState private var isNameFocused: Bool
    
    private let mintGreen = Color(red: 0.0, green: 0.82, blue: 0.58)
    
    init(window: FocusWindowModel, isNew: Bool, onSave: @escaping (FocusWindowModel) -> Void, onDelete: @escaping () -> Void) {
        self.window = window
        self.isNew = isNew
        self.onSave = onSave
        self.onDelete = onDelete
        
        _name = State(initialValue: window.name)
        _startMinutes = State(initialValue: window.startMinutes)
        _endMinutes = State(initialValue: window.endMinutes)
        _weekdays = State(initialValue: window.weekdays)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(uiColor: .systemBackground), in: Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
                // Custom close action is handled by the parent sheet usually, 
                // but we might want a custom close action if needed. 
                // We'll just rely on the swipe to dismiss or a custom dismiss environment.
                
                Spacer()
                
                if isEditingName {
                    TextField("Name", text: $name)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .focused($isNameFocused)
                        .onSubmit {
                            isEditingName = false
                        }
                } else {
                    Text(name)
                        .font(.headline)
                }
                
                Spacer()
                
                Button {
                    isEditingName.toggle()
                    if isEditingName {
                        isNameFocused = true
                    }
                } label: {
                    Image(systemName: isEditingName ? "checkmark" : "pencil")
                        .font(.body.weight(.semibold))
                        .foregroundColor(isEditingName ? .white : .primary)
                        .frame(width: 44, height: 44)
                        .background(isEditingName ? mintGreen : Color(uiColor: .systemBackground), in: Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)
            
            ScrollView {
                VStack(spacing: 24) {
                    // During this time
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "clock")
                                .font(.body.weight(.medium))
                                .frame(width: 32, height: 32)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                            Text("During this time")
                                .font(.headline.weight(.semibold))
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("From")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                
                                TimePickerButton(minutes: $startMinutes)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.body.weight(.medium))
                                .foregroundColor(.primary)
                                .padding(.top, 32)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("To")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                
                                TimePickerButton(minutes: $endMinutes)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                    
                    // On these days
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.body.weight(.medium))
                                .frame(width: 32, height: 32)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                            Text("On these day")
                                .font(.headline.weight(.semibold))
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(FocusWeekday.allCases) { day in
                                let isSelected = weekdays.contains(day.rawValue)
                                VStack(spacing: 8) {
                                    Text(day.shortTitle)
                                        .font(.headline)
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .frame(width: 38, height: 38)
                                        .background(isSelected ? mintGreen : Color(uiColor: .systemBackground), in: Circle())
                                        .overlay(
                                            Circle().stroke(Color.secondary.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
                                        )
                                    
                                    Text(day.title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onTapGesture {
                                    if isSelected {
                                        weekdays.removeAll(where: { $0 == day.rawValue })
                                    } else {
                                        weekdays.append(day.rawValue)
                                        weekdays.sort()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            
            // Bottom Buttons
            VStack(spacing: 16) {
                Button {
                    window.name = name
                    window.startMinutes = startMinutes
                    window.endMinutes = endMinutes
                    window.weekdays = weekdays
                    onSave(window)
                } label: {
                    Text("Save")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                }
                
                if !isNew {
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.vertical, 12)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
}



struct TimePickerButton: View {
    @Binding var minutes: Int
    @State private var showPicker = false
    
    // Convert minutes to Date
    private var dateValue: Binding<Date> {
        Binding(
            get: {
                let calendar = Calendar.current
                var components = DateComponents()
                components.hour = minutes / 60
                components.minute = minutes % 60
                return calendar.date(from: components) ?? Date()
            },
            set: { newDate in
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: newDate)
                let minute = calendar.component(.minute, from: newDate)
                minutes = (hour * 60) + minute
            }
        )
    }
    
    var body: some View {
        Button {
            showPicker.toggle()
        } label: {
            HStack(spacing: 8) {
                Text(String(format: "%02d : %02d", minutes / 60, minutes % 60))
                    .font(.body)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
        }
        .sheet(isPresented: $showPicker) {
            NavigationView {
                DatePicker("", selection: dateValue, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .navigationTitle("Select Time")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showPicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.height(300)])
        }
    }
}
