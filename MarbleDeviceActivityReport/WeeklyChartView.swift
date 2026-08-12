//
//  WeeklyChartView.swift
//
//  Created by Marble on 11/08/26.
//

import SwiftUI
import Charts

struct WeeklyChartView: View {
    let dailyData: [DailyScreenTime]

    private var mostDistractingDay: String {
        guard let max = dailyData.max(by: { $0.hours < $1.hours }) else { return "—" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: max.date)
    }

    private var mostProductiveDay: String {
        guard let min = dailyData.filter({ $0.hours > 0 }).min(by: { $0.hours < $1.hours }) else { return "—" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: min.date)
    }

    private func xKey(for index: Int) -> String {
        String(format: "%02d", index)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Legend at top-left
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.18, green: 0.83, blue: 0.75))
                        .frame(width: 8, height: 8)
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text("Last Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            Chart {
                ForEach(Array(dailyData.enumerated()), id: \.offset) { index, dataPoint in
                    // Last Week Bar -> Gray
                    BarMark(
                        x: .value("Day", xKey(for: index)),
                        yStart: .value("Min", 0),
                        yEnd: .value("Max", dataPoint.lastWeekHours),
                        width: .fixed(18)
                    )
                    .foregroundStyle(Color.secondary.opacity(0.3))
                    .cornerRadius(6)
                    .offset(x: -5)

                    // This Week Bar -> Teal
                    BarMark(
                        x: .value("Day", xKey(for: index)),
                        yStart: .value("Min", 0),
                        yEnd: .value("Max", dataPoint.hours),
                        width: .fixed(18)
                    )
                    .foregroundStyle(Color(red: 0.18, green: 0.83, blue: 0.75))
                    .cornerRadius(6)
                    .offset(x: 5)
                    .annotation(position: .top, alignment: .center) {
                        if dataPoint.isHighlighted {
                            Text("\(Int(dataPoint.hours))h")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel(centered: true) {
                        let idx = value.index
                        if idx < dailyData.count {
                            let dataPoint = dailyData[idx]
                            VStack(spacing: 2) {
                                Text(dataPoint.date, format: .dateTime.weekday(.narrow))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text(dataPoint.date, format: .dateTime.day())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .frame(height: 200)

            // Most Distracting / Most Productive
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Most Distracting")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(mostDistractingDay)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Most Productive")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(mostProductiveDay)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
