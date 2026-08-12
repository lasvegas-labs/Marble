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
                    // Last Week Bar -> Gray
                    BarMark(
                        x: .value("Day", dataPoint.date, unit: .day),
                        yStart: .value("Min", 0),
                        yEnd: .value("Max", dataPoint.lastWeekHours),
                        width: .fixed(20)
                    )
                    .foregroundStyle(Color.secondary.opacity(0.3))
                    .cornerRadius(8)
                    .offset(x: -6)

                    // This Week Bar -> Green
                    BarMark(
                        x: .value("Day", dataPoint.date, unit: .day),
                        yStart: .value("Min", 0),
                        yEnd: .value("Max", dataPoint.hours),
                        width: .fixed(20)
                    )
                    .foregroundStyle(Color(red: 0.18, green: 0.83, blue: 0.75))
                    .cornerRadius(8)
                    .offset(x: 6)
                    .annotation(position: .top) {
                        if dataPoint.isHighlighted {
                            Text("\(Int(dataPoint.hours))h")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            VStack(spacing: 4) {
                                Text(date, format: .dateTime.weekday(.narrow))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text(date, format: .dateTime.day())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .frame(height: 220)

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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Most Distracting")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Tuesday")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Most Productive")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Wednesday")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
