import SwiftUI

struct TopStatsView: View {
    let weeklyTotalSeconds: TimeInterval
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
        }
    }
}
