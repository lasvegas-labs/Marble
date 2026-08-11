//
//  ReportViewModel.swift
//  Created by Marble on 11/08/26.
//

import Foundation
import Combine

final class ReportViewModel: ObservableObject {
    @Published var weeklyTotalSeconds: TimeInterval
    @Published var dailyData: [DailyScreenTime] = []
    @Published var appUsage: [AppUsageEntry]
    @Published var suggestions: [ActivitySuggestion]
    @Published var showGradeTooltip = false

    @Published var selectedStartDate: Date = Calendar.current.startOfDay(for: Date().addingTimeInterval(-6 * 86400)) {
        didSet {
            generateDailyData()
        }
    }

    var grade: GradeLevel {
        GradeLevel.grade(for: weeklyTotalHours)
    }

    var weeklyTotalHours: Double {
        weeklyTotalSeconds / 3600
    }

    var formattedWeeklyTotal: String {
        let hours = Int(weeklyTotalSeconds) / 3600
        let minutes = (Int(weeklyTotalSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    init() {
        weeklyTotalSeconds = 19 * 3600 + 18 * 60 // 19h 18m

        appUsage = [
            AppUsageEntry(appName: "Discord", iconName: "message.fill", duration: 8 * 3600 + 3 * 60),
            AppUsageEntry(appName: "FaceTime", iconName: "video.fill", duration: 7 * 3600 + 3 * 60),
            AppUsageEntry(appName: "Facebook", iconName: "globe", duration: 5 * 3600 + 3 * 60),
            AppUsageEntry(appName: "Instagram", iconName: "camera.fill", duration: 4 * 3600 + 3 * 60),
            AppUsageEntry(appName: "LinkedIn", iconName: "briefcase.fill", duration: 8 * 3600 + 3 * 60),
            AppUsageEntry(appName: "Threads", iconName: "at", duration: 5 * 3600 + 3 * 60),
        ]

        suggestions = [
            ActivitySuggestion(
                iconName: "book.fill",
                title: "Read 2–3 Books",
                subtitle: "Finish around 600–900 pages"
            ),
            ActivitySuggestion(
                iconName: "figure.walk",
                title: "Walk 100,000+ Steps",
                subtitle: "Approximately 70–80 km"
            ),
            ActivitySuggestion(
                iconName: "figure.run",
                title: "20 Workout Sessions",
                subtitle: "20 minutes each"
            ),
            ActivitySuggestion(
                iconName: "paintpalette.fill",
                title: "Practice a New Skill",
                subtitle: "Drawing, guitar, cooking, photography"
            ),
        ]
        
        generateDailyData()
    }

    func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func generateDailyData() {
        var data: [DailyScreenTime] = []
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: selectedStartDate)
        
        let mockHours: [Double] = [2.5, 3.0, 2.8, 4.0, 3.2, 2.0, 1.5]
        let mockLastWeek: [Double] = [2.0, 2.5, 3.5, 3.2, 2.8, 3.0, 2.0]
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: start) {
                let isHighlighted = (i == 3) // Just mock highlight for demo
                data.append(DailyScreenTime(
                    date: date,
                    hours: mockHours[i],
                    lastWeekHours: mockLastWeek[i],
                    isHighlighted: isHighlighted
                ))
            }
        }
        
        self.dailyData = data
    }
}
