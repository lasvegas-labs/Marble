//
//  GradeTooltipView.swift
//
//  Created by Marble on 11/08/26.
//

import SwiftUI

struct GradeTooltipView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scoring level")
                .font(.headline)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(GradeLevel.allCases, id: \.self) { grade in
                    Text("Grade \(grade.rawValue) : \(grade.range)")
                        .font(.subheadline)
                }
            }

            // Button(action: { dismiss() }) {
            //     Text("Close")
            //         .frame(maxWidth: .infinity)
            //         .padding()
            //         .background(Color.secondary.opacity(0.1))
            //         .cornerRadius(8)
            //         .foregroundColor(.primary)
            // }
        }
        .padding()
    }
}
