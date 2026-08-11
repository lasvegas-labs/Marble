//
//  TimeImpactCardView.swift
//
//  Created by Marble on 11/08/26.
//

import SwiftUI

struct TimeImpactCardView: View {
    let formattedWeeklyTotal: String
    let grade: GradeLevel
    @Binding var showGradeTooltip: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Weekly you spent")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formattedWeeklyTotal)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Your Grade:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: { showGradeTooltip = true }) {
                    Text(grade.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.18, green: 0.83, blue: 0.75))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 0.18, green: 0.83, blue: 0.75), lineWidth: 2)
                        )
                }
                .popover(isPresented: $showGradeTooltip) {
                    GradeTooltipView()
                        .presentationCompactAdaptation(.sheet)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }
}
