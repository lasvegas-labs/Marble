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
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text("Your Grade:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showGradeTooltip = true }) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .popover(isPresented: $showGradeTooltip) {
                        GradeTooltipView()
                            .presentationCompactAdaptation(.popover)
                    }
                }
                
                Text(grade.rawValue)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.83, blue: 0.75))
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
