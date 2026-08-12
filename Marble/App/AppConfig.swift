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
        return "http://192.168.0.113:9090"
    }()

    static let recommendationEndpoint = "\(baseURL)/friction"

    static let appGroupIdentifier = "group.otniel"
    static let shieldStateKey = "marble_shield_state"
    static let activitySelectionKey = "saved_activity_selection"
    static let focusWindowActiveKey = "screenTime.focusWindowActive"
    static let lastTriggeredAppKey = "marble_last_triggered_app"
}
