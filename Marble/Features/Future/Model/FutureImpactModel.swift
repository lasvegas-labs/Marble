//
//  FutureImpactModel.swift
//  Marble
//
//  Created by otnielkalit on 12/08/26.
//

import Foundation

struct FutureImpactRequest: Encodable {
    let screenTimeLastWeek: Int
    let screenTimeThisWeek: Int
    let age: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case screenTimeLastWeek = "screen_time_last_week"
        case screenTimeThisWeek = "screen_time_this_week"
        case age
        case role
    }
}

struct FutureImpactCategory: Decodable, Identifiable {
    let category: String
    let message: String
    let iconSFSymbol: String

    var id: String { category }

    enum CodingKeys: String, CodingKey {
        case category
        case message
        case iconSFSymbol = "icon_sf_symbol"
    }
}

struct FutureImpactResponse: Decodable {
    let deltaHoursPerWeek: Int
    let projectionYears: Int
    let totalHours: Int
    let totalDays: Int
    let categories: [FutureImpactCategory]

    enum CodingKeys: String, CodingKey {
        case deltaHoursPerWeek = "delta_hours_per_week"
        case projectionYears = "projection_years"
        case totalHours = "total_hours"
        case totalDays = "total_days"
        case categories
    }
}
