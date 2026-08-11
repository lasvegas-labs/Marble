//
//  ReportViewModel.swift
//  Created by Marble on 11/08/26.
//

import Foundation
import Combine

final class ReportViewModel: ObservableObject {
    @Published var weeklyTotalSeconds: TimeInterval
    @Published var dailyData: [DailyScreenTime]
    @Published var appUsage: [AppUsageEntry]
    @Published var suggestions: [ActivitySuggestion]
    @Published var showGradeTooltip = false

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

        dailyData = [
            DailyScreenTime(day: "S", dayNumber: 1, hours: 2.5, lastWeekHours: 2.0, isHighlighted: false),
            DailyScreenTime(day: "M", dayNumber: 2, hours: 3.0, lastWeekHours: 2.5, isHighlighted: false),
            DailyScreenTime(day: "T", dayNumber: 3, hours: 2.8, lastWeekHours: 3.5, isHighlighted: false),
            DailyScreenTime(day: "W", dayNumber: 4, hours: 4.0, lastWeekHours: 3.2, isHighlighted: true),
            DailyScreenTime(day: "T", dayNumber: 5, hours: 3.2, lastWeekHours: 2.8, isHighlighted: false),
            DailyScreenTime(day: "F", dayNumber: 6, hours: 2.0, lastWeekHours: 3.0, isHighlighted: false),
            DailyScreenTime(day: "S", dayNumber: 7, hours: 1.5, lastWeekHours: 2.0, isHighlighted: false),
        ]

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
    }

    func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
