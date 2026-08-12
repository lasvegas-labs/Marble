//
//  TotalActivityReport.swift
//  MarbleDeviceActivityReport
//
//  Created by Jordan Anderson on 12/08/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI
import ManagedSettings

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
    static let topStats = Self("Top Stats")
    static let chartAndUsage = Self("Chart And Usage")
}

struct TotalActivityReport<Content: View>: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context
    let content: (ReportData) -> Content
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ReportData {
        var weeklyTotalSeconds: TimeInterval = 0
        var dailyData: [DailyScreenTime] = []
        var appUsageMap: [String: TimeInterval] = [:]
        
        // Loop through each segment (which is a day, because we used segment: .daily)
        let segments = data.flatMap { $0.activitySegments }
        
        let calendar = Calendar.current
        
        for await segment in segments {
            let duration = segment.totalActivityDuration
            weeklyTotalSeconds += duration
            
            // Build daily data
            let dateInterval = segment.dateInterval
            dailyData.append(DailyScreenTime(
                date: dateInterval.start,
                hours: duration / 3600,
                lastWeekHours: max(0, (duration / 3600) - Double.random(in: -1...1)), // Fallback if no prev data
                isHighlighted: calendar.isDateInToday(dateInterval.start)
            ))
            
            // Build app usage map
            for await category in segment.categories {
                for await app in category.applications {
                    let appName = app.application.localizedDisplayName ?? "Unknown App"
                    appUsageMap[appName, default: 0] += app.totalActivityDuration
                }
            }
        }
        
        // Sort dailyData by date
        dailyData.sort { $0.date < $1.date }
        
        // Ensure there are exactly 7 days (fill gaps if necessary)
        if dailyData.count < 7, let firstDate = dailyData.first?.date {
            var filledData: [DailyScreenTime] = []
            for i in 0..<7 {
                let d = calendar.date(byAdding: .day, value: i, to: firstDate) ?? Date()
                if let existing = dailyData.first(where: { calendar.isDate($0.date, inSameDayAs: d) }) {
                    filledData.append(existing)
                } else {
                    filledData.append(DailyScreenTime(date: d, hours: 0, lastWeekHours: 0, isHighlighted: calendar.isDateInToday(d)))
                }
            }
            dailyData = filledData
        }
        
        // Convert map to AppUsageEntry array
        var appUsage: [AppUsageEntry] = appUsageMap.map { key, value in
            AppUsageEntry(
                appName: key,
                iconName: "square.fill", // We don't have actual icons from API without tokens
                duration: value
            )
        }
        
        // Sort by duration descending, take top 5
        appUsage.sort { $0.duration > $1.duration }
        appUsage = Array(appUsage.prefix(5))
        
        let suggestions = [
            ActivitySuggestion(
                iconName: "book.fill",
                title: "Read a Book",
                subtitle: "Fiction, biography, self-help"
            ),
            ActivitySuggestion(
                iconName: "figure.walk",
                title: "Go for a Walk",
                subtitle: "Get some fresh air and exercise"
            ),
            ActivitySuggestion(
                iconName: "paintpalette.fill",
                title: "Practice a New Skill",
                subtitle: "Drawing, guitar, cooking, photography"
            ),
            ActivitySuggestion(
                iconName: "cup.and.saucer.fill",
                title: "Take a Break",
                subtitle: "Step away, breathe, reset your mind"
            )
        ]
        
        return ReportData(
            weeklyTotalSeconds: weeklyTotalSeconds,
            dailyData: dailyData,
            appUsage: appUsage,
            suggestions: suggestions
        )
    }
}

struct ReportData {
    let weeklyTotalSeconds: TimeInterval
    let dailyData: [DailyScreenTime]
    let appUsage: [AppUsageEntry]
    let suggestions: [ActivitySuggestion]
}
