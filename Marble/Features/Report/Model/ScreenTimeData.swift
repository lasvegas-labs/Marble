//
//  ScreenTimeData.swift
//
//  Created by Marble on 11/08/26.
//

import Foundation

struct DailyScreenTime: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
    let lastWeekHours: Double
    let isHighlighted: Bool
}

struct AppUsageEntry: Identifiable {
    let id = UUID()
    let appName: String
    let iconName: String
    let duration: TimeInterval
}

struct ActivitySuggestion: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let subtitle: String
}
