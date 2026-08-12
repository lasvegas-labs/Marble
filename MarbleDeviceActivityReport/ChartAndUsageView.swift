import SwiftUI

struct ChartAndUsageView: View {
    let dailyData: [DailyScreenTime]
    let appUsage: [AppUsageEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Weekly Chart
            WeeklyChartView(dailyData: dailyData)

            // App Usage
            VStack(alignment: .leading, spacing: 8) {
                Text("Detail Screen Usage")
                    .font(.headline)
                    .fontWeight(.bold)
                
                VStack(spacing: 0) {
                    // Maximum duration for the bar scales (e.g. 12 hours)
                    let maxDuration: TimeInterval = 12 * 3600
                    ForEach(appUsage) { entry in
                        AppUsageRowView(entry: entry, maxDuration: maxDuration)
                        if entry.id != appUsage.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
        }
    }
}
