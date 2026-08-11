import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import UserNotifications

// This extension is invoked in the background by iOS when cumulative device activity events reach their threshold
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    private let focusStore = ManagedSettingsStore(
        named: ManagedSettingsStore.Name("marble.focus")
    )
    private let appGroupID = "group.com.lasvegas.Marblefahmi1"
    private let savedSelectionKey = "saved_activity_selection"
    private let stateKey = "marble_shield_state"
    private let focusWindowActiveKey = "screenTime.focusWindowActive"
    private let focusActivityPrefix = "marble.focus."
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        guard isFocusActivity(activity) else { return }

        guard let selection = savedSelection(), hasSelection(selection) else {
            setFocusWindowActive(false)
            clearFocusShield()
            return
        }

        setFocusWindowActive(true)
        applyFocusShield(for: selection)
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        guard isFocusActivity(activity) else { return }

        clearFocusShield()
        setFocusWindowActive(false)
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // 1. Set shield state to fifteenMinuteThreshold FIRST to avoid race condition
        sharedDefaults?.set("fifteenMinuteThreshold", forKey: stateKey)
        sharedDefaults?.synchronize()
        
        // 2. Re-apply shield to the discouraged applications
        reapplyShield()
        
        // 3. Post a debug notification to visually confirm execution
        sendDebugNotification()
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
        guard let selection = savedSelection() else {
            return
        }
        
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(categories)
        store.shield.webDomainCategories = categories.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(categories)
    }

    private func savedSelection() -> FamilyActivitySelection? {
        guard let data = sharedDefaults?.data(forKey: savedSelectionKey) else {
            return nil
        }

        return try? PropertyListDecoder().decode(
            FamilyActivitySelection.self,
            from: data
        )
    }

    private func hasSelection(_ selection: FamilyActivitySelection) -> Bool {
        !selection.applicationTokens.isEmpty
            || !selection.categoryTokens.isEmpty
            || !selection.webDomainTokens.isEmpty
    }

    private func isFocusActivity(_ activity: DeviceActivityName) -> Bool {
        activity.rawValue.hasPrefix(focusActivityPrefix)
    }

    private func applyFocusShield(for selection: FamilyActivitySelection) {
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        let webDomains = selection.webDomainTokens

        focusStore.shield.applications = applications.isEmpty ? nil : applications
        focusStore.shield.applicationCategories = categories.isEmpty
            ? nil
            : .specific(categories)
        focusStore.shield.webDomains = webDomains.isEmpty ? nil : webDomains
        focusStore.shield.webDomainCategories = categories.isEmpty
            ? nil
            : .specific(categories)
    }

    private func clearFocusShield() {
        focusStore.shield.applications = nil
        focusStore.shield.applicationCategories = nil
        focusStore.shield.webDomains = nil
        focusStore.shield.webDomainCategories = nil
    }

    private func setFocusWindowActive(_ isActive: Bool) {
        sharedDefaults?.set(isActive, forKey: focusWindowActiveKey)
        sharedDefaults?.synchronize()
    }
    
    private func sendDebugNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Marble Alert ⏰"
        content.body = "1 minute cumulative usage threshold has been reached!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "threshold_reached_debug",
            content: content,
            trigger: nil // immediate
        )
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
