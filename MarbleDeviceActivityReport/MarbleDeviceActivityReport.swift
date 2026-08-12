//
//  MarbleDeviceActivityReport.swift
//  MarbleDeviceActivityReport
//
//  Created by Jordan Anderson on 12/08/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct MarbleDeviceActivityReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport(context: .totalActivity) { reportData in
            TotalActivityView(
                weeklyTotalSeconds: reportData.weeklyTotalSeconds,
                dailyData: reportData.dailyData,
                appUsage: reportData.appUsage,
                suggestions: reportData.suggestions
            )
        }
        
        TotalActivityReport(context: .topStats) { reportData in
            TopStatsView(
                weeklyTotalSeconds: reportData.weeklyTotalSeconds,
                suggestions: reportData.suggestions
            )
        }
        
        TotalActivityReport(context: .chartAndUsage) { reportData in
            ChartAndUsageView(
                dailyData: reportData.dailyData,
                appUsage: reportData.appUsage
            )
        }
    }
}
