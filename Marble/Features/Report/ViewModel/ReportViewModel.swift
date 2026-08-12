//
//  ReportViewModel.swift
//  Created by Marble on 11/08/26.
//

import Foundation
import Combine

final class ReportViewModel: ObservableObject {
    @Published var selectedStartDate: Date = {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
    }()
    
    var dateRangeText: String {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: selectedStartDate) ?? selectedStartDate
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return "\(formatter.string(from: selectedStartDate)) - \(formatter.string(from: end))"
    }

    init() {}
}

