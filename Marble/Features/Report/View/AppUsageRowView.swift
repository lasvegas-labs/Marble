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
            Image(systemName: entry.iconName)
                .font(.title2)
                .frame(width: 32, height: 32)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.appName)
                    .font(.subheadline)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 8)

                        Capsule()
                            .fill(Color(red: 0.18, green: 0.83, blue: 0.75))
                            .frame(width: max(0, geometry.size.width * CGFloat(entry.duration / maxDuration)), height: 8)
                    }
                }
                .frame(height: 8)
            }

            Text(formattedDuration(entry.duration))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
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
}
