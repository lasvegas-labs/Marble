import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

// This extension is invoked in the background by iOS when cumulative device activity events reach their threshold
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    private let appGroupID = "group.com.lasvegas.Marblefahmi1"
    private let savedSelectionKey = "saved_activity_selection"
    private let stateKey = "marble_shield_state"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // 1. Re-apply shield to the discouraged applications
        reapplyShield()
        
        // 2. Set shield state to fifteenMinuteThreshold
        sharedDefaults?.set("fifteenMinuteThreshold", forKey: stateKey)
        sharedDefaults?.synchronize()
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
    
    private func reapplyShield() {
        guard let data = sharedDefaults?.data(forKey: savedSelectionKey),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }
        
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
    }
}
