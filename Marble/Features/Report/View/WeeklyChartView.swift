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
                    // Last Week
                    BarMark(
                        x: .value("Day", dataPoint.day),
                        yStart: .value("Min", 0),
                        yEnd: .value("Max", dataPoint.lastWeekHours)
                    )
                    .foregroundStyle(Color.secondary.opacity(0.3))

                    // This Week
                    BarMark(
                        x: .value("Day", dataPoint.day),
                        yStart: .value("Min", 0),
                        yEnd: .value("Max", dataPoint.hours)
                    )
                    .foregroundStyle(Color(red: 0.18, green: 0.83, blue: 0.75))
                    .annotation(position: .top) {
                        if dataPoint.isHighlighted {
                            Text("\(Int(dataPoint.hours))h")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .frame(height: 150)

            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.83, blue: 0.75))
                            .frame(width: 8, height: 8)
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text("Last Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                HStack {
                    Text("Most Distracting: Tuesday")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Most Productive: Wednesday")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 16)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
