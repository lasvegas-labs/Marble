//
//  ReportView.swift
//  Created by Marble on 11/08/26.
//

import SwiftUI

struct ReportView: View {
    @StateObject private var viewModel: ReportViewModel
    @EnvironmentObject private var router: AppRouter

    init(viewModel: ReportViewModel = ReportViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time Impact")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("See the real cost of your screen time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Card
                TimeImpactCardView(
                    formattedWeeklyTotal: viewModel.formattedWeeklyTotal,
                    grade: viewModel.grade,
                    showGradeTooltip: $viewModel.showGradeTooltip
                )

                // Suggestions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instead, you could have . . .")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 0) {
                        ForEach(viewModel.suggestions) { suggestion in
                            ActivitySuggestionView(suggestion: suggestion)
                            if suggestion.id != viewModel.suggestions.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }

                // Time Spend
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time Spend")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("August")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Week segmented picker
                        Picker("Week", selection: .constant("1-7")) {
                            Text("1-7").tag("1-7")
                            Text("8-14").tag("8-14")
                            Text("15-21").tag("15-21")
                            Text("22-30").tag("22-30")
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    
                    WeeklyChartView(dailyData: viewModel.dailyData)
                }

                // Detail Screen Usage
                VStack(alignment: .leading, spacing: 8) {
                    Text("Detail Screen Usage")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 0) {
                        let maxDuration: TimeInterval = 12 * 3600
                        ForEach(viewModel.appUsage) { entry in
                            AppUsageRowView(entry: entry, maxDuration: maxDuration)
                            if entry.id != viewModel.appUsage.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
