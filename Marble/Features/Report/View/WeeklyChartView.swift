//
//  WeeklyChartView.swift
//
//  Created by Marble on 11/08/26.
//

import SwiftUI
import Charts

struct WeeklyChartView: View {
    let dailyData: [DailyScreenTime]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Chart {
                ForEach(dailyData) { dataPoint in
                    BarMark(
                        x: .value("Day", dataPoint.day),
                        y: .value("Hours", dataPoint.hours)
                    )
                    .foregroundStyle(dataPoint.isHighlighted ? Color(red: 0.18, green: 0.83, blue: 0.75) : Color.secondary.opacity(0.3))
                    .annotation(position: .top) {
                        if dataPoint.isHighlighted {
                            Text("\(Int(dataPoint.hours))hr")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 150)

            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.83, blue: 0.75))
                            .frame(width: 8, height: 8)
                        Text("Most Distracting: Tuesday")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text("Most Productive: Wednesday")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }
}
