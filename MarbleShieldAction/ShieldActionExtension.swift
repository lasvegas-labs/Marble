import ManagedSettings
import UserNotifications

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
        switch action {
        case .primaryButtonPressed: // "Show The Recommendation"
            // Trigger a local notification to deep-link the user into the Marble app
            sendRecommendationNotification()
            
            // Close the shielded app immediately (returns user to home screen)
            completionHandler(.close)
            
        case .secondaryButtonPressed: // "Continue Scrolling"
            // Temporarily lift the shield for this app by removing it from the store
            liftShield(for: application)
            
            // .none indicates no additional action is needed from the system,
            // as we already removed the shield, allowing the app to open.
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
        switch action {
        case .primaryButtonPressed: // "Show The Recommendation"
            sendRecommendationNotification()
            completionHandler(.close)
            
        case .secondaryButtonPressed: // "Continue Scrolling"
            liftShield(for: category)
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
        switch action {
        case .primaryButtonPressed:
            sendRecommendationNotification()
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            let store = ManagedSettingsStore()
            if var webDomains = store.shield.webDomains {
                webDomains.remove(webDomain)
                store.shield.webDomains = webDomains
            }
            completionHandler(.none)
            
        default:
            completionHandler(.none)
        }
    }
    
    // MARK: - Logic Helpers (marked nonisolated to match calling context)
    
    nonisolated private func liftShield(for application: ApplicationToken) {
        let store = ManagedSettingsStore()
        
        if var applications = store.shield.applications {
            applications.remove(application)
            store.shield.applications = applications
        }
    }
    
    nonisolated private func liftShield(for category: ActivityCategoryToken) {
        let store = ManagedSettingsStore()
        
        if case .specific(var categories, let exclusions) = store.shield.applicationCategories {
            categories.remove(category)
            store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories, except: exclusions)
        }
    }
    
    nonisolated private func sendRecommendationNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Marble Recommendation 💡"
        content.body = "Tap here to see your fun recommendation!"
        content.sound = .default
        content.userInfo = ["url": "marble://recommendation"]
        
        // Fire after 1 second
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
}
