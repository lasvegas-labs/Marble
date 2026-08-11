//
//  ReportView.swift
//
//  Created by Marble on 11/08/26.
//

import SwiftUI

struct ReportView: View {
    @StateObject private var viewModel: ReportViewModel
    @EnvironmentObject private var router: AppRouter

    init(viewModel: ReportViewModel) {
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
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                }

                // Time Spend
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Time Spend")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text("August")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Week pills (static mock)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["1-7", "8-14", "15-21", "22-30"], id: \.self) { week in
                                Text(week)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(week == "1-7" ? Color(red: 0.18, green: 0.83, blue: 0.75) : Color.secondary.opacity(0.1))
                                    .foregroundColor(week == "1-7" ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    WeeklyChartView(dailyData: viewModel.dailyData)
                }

                // Detail Screen Usage
                VStack(alignment: .leading, spacing: 8) {
                    Text("Detail Screen Usage")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 0) {
                        let maxDuration = viewModel.appUsage.map { $0.duration }.max() ?? 1
                        ForEach(viewModel.appUsage) { entry in
                            AppUsageRowView(entry: entry, maxDuration: maxDuration)
                            if entry.id != viewModel.appUsage.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
