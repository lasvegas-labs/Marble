//
//  AppConfig.swift
//  Marble
//
//  Created by otnielkalit on 12/08/26.
//

import Foundation

enum AppConfig {
    static let baseURL: String = {
        if let url = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String, !url.isEmpty {
            return url
        }
        return "https://my-plenger.pt-tensakarya.com"
    }()

    static let recommendationEndpoint = "\(baseURL)/friction"
    static let futureImpactEndpoint = "\(baseURL)/future-impact"

    static let appGroupIdentifier = "group.com.otniel.Marble"
    static let shieldStateKey = "marble_shield_state"
    static let activitySelectionKey = "saved_activity_selection"
    static let focusWindowActiveKey = "screenTime.focusWindowActive"
    static let lastTriggeredAppKey = "marble_last_triggered_app"
}
