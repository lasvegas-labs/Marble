import Foundation
import Intents
import ManagedSettings
import UserNotifications
import DeviceActivity
import FamilyControls

public enum MarbleShieldState: String, Codable {
    case friction
    case fifteenMinuteThreshold
    case waitingForNotification
    case focusActive
}

public final class ShieldStateManager {
    public static let shared = ShieldStateManager()
    
    private let appGroupID = "group.com.lasvegas.Marblefahmi1"
    private let stateKey = "marble_shield_state"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    public var currentState: MarbleShieldState {
        get {
            guard let rawValue = userDefaults?.string(forKey: stateKey),
                  let state = MarbleShieldState(rawValue: rawValue) else {
                return .friction
            }
            return state
        }
        set {
            userDefaults?.set(newValue.rawValue, forKey: stateKey)
            userDefaults?.synchronize()
        }
    }
    
    public func reset() {
        currentState = .friction
    }
}

// This extension handles the button clicks (Primary and Secondary) on the shield screen
class ShieldActionExtension: ShieldActionDelegate {
    
    nonisolated override init() {
        super.init()
    }
    
    // Handles actions when a specific application is shielded
    nonisolated override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        guard !isScheduledFocusWindowActive else {
            completionHandler(.defer)
            return
        }

        switch action {
        case .primaryButtonPressed:
            handlePrimaryAction(completionHandler: completionHandler)
            
        case .secondaryButtonPressed:
            liftShield(for: application)
            ShieldStateManager.shared.reset()
            resetMonitoring()
            completionHandler(.none)
            
        default:
            completionHandler(.none)
        }
    }
    
    // Handles actions when a whole category is shielded
    nonisolated override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        guard !isScheduledFocusWindowActive else {
            completionHandler(.defer)
            return
        }

        switch action {
        case .primaryButtonPressed:
            handlePrimaryAction(completionHandler: completionHandler)
            
        case .secondaryButtonPressed:
            liftShield(for: category)
            ShieldStateManager.shared.reset()
            resetMonitoring()
            completionHandler(.none)
            
        default:
            completionHandler(.none)
        }
    }
    
    // Handles actions when a web domain is shielded
    nonisolated override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        guard !isScheduledFocusWindowActive else {
            completionHandler(.defer)
            return
        }

        switch action {
        case .primaryButtonPressed:
            handlePrimaryAction(completionHandler: completionHandler)
            
        case .secondaryButtonPressed:
            liftShield(for: webDomain)
            ShieldStateManager.shared.reset()
            resetMonitoring()
            completionHandler(.none)
            
        default:
            completionHandler(.none)
        }
    }
    
    // MARK: - Action Helpers

    nonisolated private var isScheduledFocusWindowActive: Bool {
        UserDefaults(suiteName: "group.com.lasvegas.Marblefahmi1")?
            .bool(forKey: "screenTime.focusWindowActive") ?? false
    }
    
    nonisolated private func handlePrimaryAction(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let currentState = ShieldStateManager.shared.currentState
        
        switch currentState {
        case .friction, .fifteenMinuteThreshold:
            // User tapped "Show The Recommendation" from initial friction or 15-minute threshold
            sendRecommendationNotification()
            ShieldStateManager.shared.currentState = .waitingForNotification
            completionHandler(.defer)
            
        case .waitingForNotification:
            // User tapped "Didn't See The Notification"
            let isFocused = INFocusStatusCenter.default.focusStatus.isFocused ?? false
            if isFocused {
                ShieldStateManager.shared.currentState = .focusActive
            } else {
                sendRecommendationNotification()
                ShieldStateManager.shared.currentState = .waitingForNotification
            }
            completionHandler(.defer)
            
        case .focusActive:
            // User tapped "Try Again"
            let isFocused = INFocusStatusCenter.default.focusStatus.isFocused ?? false
            if isFocused {
                ShieldStateManager.shared.currentState = .focusActive
            } else {
                sendRecommendationNotification()
                ShieldStateManager.shared.currentState = .waitingForNotification
            }
            completionHandler(.defer)
        }
    }
    
    // MARK: - Logic Helpers
    
    nonisolated private func liftShield(for application: ApplicationToken) {
        let store = ManagedSettingsStore()
        if var applications = store.shield.applications {
            applications.remove(application)
            store.shield.applications = applications.isEmpty ? nil : applications
        }
        if case .specific(let categories, var exclusions) = store.shield.applicationCategories {
            exclusions.insert(application)
            store.shield.applicationCategories = .specific(categories, except: exclusions)
        }
    }
    
    nonisolated private func liftShield(for application: ApplicationToken, in category: ActivityCategoryToken) {
        liftShield(for: application)
    }
    
    nonisolated private func liftShield(for category: ActivityCategoryToken) {
        let store = ManagedSettingsStore()
        if case .specific(var categories, let exclusions) = store.shield.applicationCategories {
            categories.remove(category)
            store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories, except: exclusions)
        }
    }
    
    nonisolated private func liftShield(for webDomain: WebDomainToken) {
        let store = ManagedSettingsStore()
        if var webDomains = store.shield.webDomains {
            webDomains.remove(webDomain)
            store.shield.webDomains = webDomains.isEmpty ? nil : webDomains
        }
        if case .specific(let categories, var exclusions) = store.shield.webDomainCategories {
            exclusions.insert(webDomain)
            store.shield.webDomainCategories = .specific(categories, except: exclusions)
        }
    }
    
    nonisolated private func liftShield(for webDomain: WebDomainToken, in category: ActivityCategoryToken) {
        liftShield(for: webDomain)
    }
    
    nonisolated private func sendRecommendationNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Marble"
        content.body = "Click to see activity recommendations"
        content.sound = .default
        content.userInfo = ["url": "marble://recommendation"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "marble_recommendation",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    nonisolated private func resetMonitoring() {
        let center = DeviceActivityCenter()
        let activityName = DeviceActivityName("marble.usage.monitoring")
        center.stopMonitoring([activityName])
        
        let appGroupID = "group.com.lasvegas.Marblefahmi1"
        let savedSelectionKey = "saved_activity_selection"
        let sharedDefaults = UserDefaults(suiteName: appGroupID)
        
        guard let data = sharedDefaults?.data(forKey: savedSelectionKey),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }
        
        let hasApps = !selection.applicationTokens.isEmpty
        let hasCategories = !selection.categoryTokens.isEmpty
        let hasWebDomains = !selection.webDomainTokens.isEmpty
        
        guard hasApps || hasCategories || hasWebDomains else { return }
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        
        let thresholdMinutes = sharedDefaults?.integer(forKey: "usage_threshold_minutes") ?? 15
        let durationMinutes = thresholdMinutes > 0 ? thresholdMinutes : 15
        
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: durationMinutes)
        )
        
        do {
            try center.startMonitoring(
                activityName,
                during: schedule,
                events: [DeviceActivityEvent.Name("marble.usage.threshold.15mins"): event]
            )
        } catch {
            print("ShieldActionExtension: Failed to restart monitoring: \(error)")
        }
    }
}
