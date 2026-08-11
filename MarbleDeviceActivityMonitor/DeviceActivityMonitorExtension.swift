import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        guard let selection = loadSelection() else {
            clearShields()
            return
        }

        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil
            : selection.webDomainTokens
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        clearShields()
    }

    private func loadSelection() -> FamilyActivitySelection? {
        guard
            let defaults = UserDefaults(suiteName: "group.com.lasvegas.MarbleSande"),
            let data = defaults.data(forKey: "screenTime.familyActivitySelection")
        else {
            return nil
        }

        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    private func clearShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
}
