import ManagedSettings
import Foundation
import UIKit
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // "See Recommendation"
            // Schedule a local notification to appear 0.5 seconds after returning to the home screen.
            let content = UNMutableNotificationContent()
            content.title = "Marble Recommendation"
            content.body = "Tap here to see your fun recommendation!"
            content.sound = .default
            
            // Add a slight delay to ensure it pops up AFTER the shield closes and user is on the home screen
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
                // Close the shielded app to return to home screen
                completionHandler(.close)
            }
            
        case .secondaryButtonPressed:
            // "Continue Scrolling" - unblock the app instantly
            let store = ManagedSettingsStore() // Use default store to avoid App Group crash
            if var applications = store.shield.applications {
                applications.remove(application)
                store.shield.applications = applications.isEmpty ? nil : applications
            } else {
                store.shield.applications = nil
            }
            
            // Use .defer on a physical device. It tells iOS to check the store.
            // Since we just removed the app from the store, iOS will instantly dismiss the shield
            // and the user will stay inside the app!
            completionHandler(.defer)
            
        @unknown default:
            completionHandler(.defer)
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.defer)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.defer)
    }
}
