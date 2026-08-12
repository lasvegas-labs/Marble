import SwiftUI

struct TotalActivityView: View {
    let weeklyTotalSeconds: TimeInterval
    let dailyData: [DailyScreenTime]
    let appUsage: [AppUsageEntry]
    let suggestions: [ActivitySuggestion]
    
    var grade: GradeLevel {
        GradeLevel.grade(for: weeklyTotalSeconds / 3600)
    }
    
    var formattedWeeklyTotal: String {
        let hours = Int(weeklyTotalSeconds) / 3600
        let minutes = (Int(weeklyTotalSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    @State private var showGradeTooltip = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Weekly Chart
            WeeklyChartView(dailyData: dailyData)

            // Card
            TimeImpactCardView(
                formattedWeeklyTotal: formattedWeeklyTotal,
                grade: grade,
                showGradeTooltip: $showGradeTooltip
            )

            // Suggestions
            VStack(alignment: .leading, spacing: 8) {
                Text("Instead, you could have . . .")
                    .font(.headline)
                    .fontWeight(.bold)
                
                VStack(spacing: 0) {
                    ForEach(suggestions) { suggestion in
                        ActivitySuggestionView(suggestion: suggestion)
                        if suggestion.id != suggestions.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }


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
