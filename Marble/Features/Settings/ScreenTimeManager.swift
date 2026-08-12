import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI
import UserNotifications

@MainActor
public class ScreenTimeManager: ObservableObject {
    public static let shared = ScreenTimeManager()
    
    // Configurable cumulative usage threshold
    public static let defaultThresholdMinutes: Int = 15
    public static let activityName = DeviceActivityName("marble.usage.monitoring")
    public static let eventName = DeviceActivityEvent.Name("marble.usage.threshold.15mins")
    
    private let appGroupID = "group.com.lasvegas.Marblefahmi1"
    private let savedSelectionKey = "saved_activity_selection"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    @Published public var hasAuthorization = false
    @Published public var usageThresholdMinutes: Int = ScreenTimeManager.defaultThresholdMinutes
    
    @Published public var selectionToDiscourage = FamilyActivitySelection() {
        didSet {
            saveSelection()
            applyShield()
            updateDeviceActivityMonitoring()
        }
    }
    
    let store = ManagedSettingsStore()
    let activityCenter = DeviceActivityCenter()
    
    private init() {
        loadSavedSelection()
        checkAuthorizationStatus()
        applyShield()
        updateDeviceActivityMonitoring()
    }
    
    public func checkAuthorizationStatus() {
        hasAuthorization = Self.isApproved(
            AuthorizationCenter.shared.authorizationStatus
        )
    }
    
    public func requestAuthorization() {
        Task {
            await requestAuthorizationAsync()
        }
    }

    public func requestAuthorizationAsync() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            hasAuthorization = Self.isApproved(
                AuthorizationCenter.shared.authorizationStatus
            )
            if hasAuthorization {
                updateDeviceActivityMonitoring()
            }
        } catch {
            print("Failed to authorize Family Controls: \(error)")
            hasAuthorization = false
        }
    }
    
    public func applyShield() {
        let applications = selectionToDiscourage.applicationTokens
        let categories = selectionToDiscourage.categoryTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
    }
    
    public func updateDeviceActivityMonitoring() {
        let hasApps = !selectionToDiscourage.applicationTokens.isEmpty
        let hasCategories = !selectionToDiscourage.categoryTokens.isEmpty
        let hasWebDomains = !selectionToDiscourage.webDomainTokens.isEmpty
        
        guard hasAuthorization, (hasApps || hasCategories || hasWebDomains) else {
            print("ScreenTimeManager: Skipping startMonitoring. Authorized: \(hasAuthorization), Has Selection: \(hasApps || hasCategories || hasWebDomains)")
            activityCenter.stopMonitoring([Self.activityName])
            return
        }
        
        // Schedule across the full 24-hour day to accumulate usage regardless of time of day
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        
        // Cumulative usage threshold (15 minutes)
        let event = DeviceActivityEvent(
            applications: selectionToDiscourage.applicationTokens,
            categories: selectionToDiscourage.categoryTokens,
            webDomains: selectionToDiscourage.webDomainTokens,
            threshold: DateComponents(minute: usageThresholdMinutes)
        )
        
        do {
            try activityCenter.startMonitoring(
                Self.activityName,
                during: schedule,
                events: [Self.eventName: event]
            )
            print("Successfully started monitoring DeviceActivity: \(Self.activityName)")
        } catch {
            print("Failed to start DeviceActivity monitoring: \(error)")
        }
    }
    
    private func saveSelection() {
        guard let data = try? PropertyListEncoder().encode(selectionToDiscourage) else { return }
        sharedDefaults?.set(data, forKey: savedSelectionKey)
        sharedDefaults?.set(usageThresholdMinutes, forKey: "usage_threshold_minutes")
        sharedDefaults?.synchronize()
    }
    
    private func loadSavedSelection() {
        guard let data = sharedDefaults?.data(forKey: savedSelectionKey),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }
        self.selectionToDiscourage = selection
    }
    
    public func simulateThresholdReached() {
        sharedDefaults?.set("fifteenMinuteThreshold", forKey: "marble_shield_state")
        sharedDefaults?.synchronize()
        applyShield()
        print("ScreenTimeManager: Simulated 15-minute threshold reached! Shield re-applied.")
    }

    private static func isApproved(_ status: AuthorizationStatus) -> Bool {
        if status == .approved { return true }

        #if compiler(>=6.3)
        if #available(iOS 26.4, *), status == .approvedWithDataAccess {
            return true
        }
        #endif

        return false
    }
}
