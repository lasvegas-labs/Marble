//
//  AppUsageRowView.swift
//
//  Created by Marble on 11/08/26.
//

import SwiftUI

struct AppUsageRowView: View {
    let entry: AppUsageEntry
    let maxDuration: TimeInterval

    var body: some View {
        HStack(spacing: 12) {
            // App icon placeholder: colored rounded square with initial
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor(for: entry.appName))
                    .frame(width: 32, height: 32)
                Text(String(entry.appName.prefix(1)).uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(entry.appName)
                .font(.subheadline)
                .lineLimit(1)
                .frame(maxWidth: 90, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(Color(red: 0.18, green: 0.83, blue: 0.75))
                        .frame(width: max(0, geometry.size.width * CGFloat(min(entry.duration / maxDuration, 1.0))), height: 8)
                }
            }
            .frame(height: 8)

            Text(formattedDuration(entry.duration))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func iconColor(for name: String) -> Color {
        let palette: [Color] = [
            Color(red: 0.18, green: 0.83, blue: 0.75),
            Color(red: 0.4, green: 0.5, blue: 0.9),
            Color(red: 0.9, green: 0.45, blue: 0.45),
            Color(red: 0.95, green: 0.65, blue: 0.2),
            Color(red: 0.5, green: 0.8, blue: 0.4),
            Color(red: 0.7, green: 0.4, blue: 0.9),
        ]
        let idx = abs(name.hashValue) % palette.count
        return palette[idx]
    }
}
