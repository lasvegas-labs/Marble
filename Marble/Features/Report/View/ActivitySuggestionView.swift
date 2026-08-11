//
//  ActivitySuggestionView.swift
//
//  Created by Marble on 11/08/26.
//

import SwiftUI

struct ActivitySuggestionView: View {
    let suggestion: ActivitySuggestion

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: suggestion.iconName)
                        .foregroundColor(.black)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(suggestion.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
