import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

enum ScreenTimeStorage {
    static let appGroupIdentifier = "group.otniel"
    static let selectionKey = "saved_activity_selection"
    static let thresholdMinutesKey = "usage_threshold_minutes"
    static let focusWindowActiveKey = "screenTime.focusWindowActive"
    static let usageActivityName = DeviceActivityName("marble.usage.monitoring")
    static let usageEventName = DeviceActivityEvent.Name("marble.usage.threshold.15mins")
    static let focusStoreName = ManagedSettingsStore.Name("marble.focus")
    static let defaultThresholdMinutes = 15
}

enum ScreenTimeServiceError: LocalizedError {
    case unavailableSharedStorage

    var errorDescription: String? {
        "Screen Time preferences could not be saved."
    }
}

@MainActor
final class ScreenTimeService {
    private let authorizationCenter = AuthorizationCenter.shared
    private let activityCenter = DeviceActivityCenter()
    private let defaultStore = ManagedSettingsStore()
    private let focusStore = ManagedSettingsStore(named: ScreenTimeStorage.focusStoreName)
    private let sharedDefaults: UserDefaults?

    init() {
        sharedDefaults = UserDefaults(
            suiteName: ScreenTimeStorage.appGroupIdentifier
        )
    }

    init(sharedDefaults: UserDefaults?) {
        self.sharedDefaults = sharedDefaults
    }

    var authorizationStatus: ScreenTimePermissionStatus {
        mapAuthorizationStatus(authorizationCenter.authorizationStatus)
    }

    func requestAuthorization() async -> ScreenTimePermissionStatus {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            return authorizationStatus
        } catch is CancellationError {
            return authorizationStatus
        } catch {
            let currentStatus = authorizationStatus
            return currentStatus == .denied ? .denied : .failed
        }
    }

    func loadSelection() -> FamilyActivitySelection {
        guard
            let data = sharedDefaults?.data(forKey: ScreenTimeStorage.selectionKey),
            let selection = try? PropertyListDecoder().decode(
                FamilyActivitySelection.self,
                from: data
            )
        else {
            return FamilyActivitySelection()
        }

        return selection
    }

    func saveSelection(_ selection: FamilyActivitySelection) throws {
        guard let sharedDefaults else {
            throw ScreenTimeServiceError.unavailableSharedStorage
        }

        let data = try PropertyListEncoder().encode(selection)
        sharedDefaults.set(data, forKey: ScreenTimeStorage.selectionKey)
        sharedDefaults.set(
            ScreenTimeStorage.defaultThresholdMinutes,
            forKey: ScreenTimeStorage.thresholdMinutesKey
        )
        sharedDefaults.synchronize()
    }

    func clearSelection() {
        sharedDefaults?.removeObject(forKey: ScreenTimeStorage.selectionKey)
        sharedDefaults?.removeObject(forKey: ScreenTimeStorage.thresholdMinutesKey)
        sharedDefaults?.synchronize()
        stopUsageMonitoring()
        stopFocusMonitoring()
    }

    func configureUsageMonitoring(
        for selection: FamilyActivitySelection
    ) throws -> Bool {
        activityCenter.stopMonitoring([ScreenTimeStorage.usageActivityName])

        guard authorizationStatus.isApproved, Self.hasSelection(selection) else {
            clearDefaultShield()
            return false
        }

        // Removed applyDefaultShield(for: selection) here so apps aren't blocked 24/7.
        // The shield will be applied when the threshold is reached in DeviceActivityMonitor.

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(
                minute: ScreenTimeStorage.defaultThresholdMinutes
            )
        )

        try activityCenter.startMonitoring(
            ScreenTimeStorage.usageActivityName,
            during: schedule,
            events: [ScreenTimeStorage.usageEventName: event]
        )
        return true
    }

    func configureFocusMonitoring(
        for selection: FamilyActivitySelection,
        focusWindows: [FocusWindowModel]
    ) throws -> Bool {
        stopFocusMonitoring()

        guard
            authorizationStatus.isApproved,
            Self.hasSelection(selection),
            !focusWindows.isEmpty
        else {
            return false
        }

        var schedulesToStart: [(DeviceActivityName, DeviceActivitySchedule)] = []

        for window in focusWindows {
            for weekdayRaw in window.weekdays {
                guard let weekday = FocusWeekday(rawValue: weekdayRaw) else { continue }
                if let schedule = Self.focusSchedule(
                    startMinutes: window.startMinutes,
                    endMinutes: window.endMinutes,
                    weekday: weekday
                ) {
                    schedulesToStart.append((Self.focusActivityName(for: window.id, weekday: weekday), schedule))
                }
            }
        }

        guard !schedulesToStart.isEmpty else { return false }

        do {
            for (activityName, schedule) in schedulesToStart {
                try activityCenter.startMonitoring(
                    activityName,
                    during: schedule
                )
            }
            // MANUALLY APPLY SHIELD IF WE ARE CURRENTLY IN ANY WINDOW
            if isCurrentlyInFocusWindow(focusWindows) {
                applyFocusShield(for: selection)
            } else {
                clearFocusShield()
            }
            
            return true
        } catch {
            stopFocusMonitoring()
            throw error
        }
    }
    
    private func applyFocusShield(for selection: FamilyActivitySelection) {
        focusStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        focusStore.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        focusStore.shield.webDomainCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
    }
    
    private func isCurrentlyInFocusWindow(_ windows: [FocusWindowModel]) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        let currentWeekday = calendar.component(.weekday, from: now) // 1 = Sun, 2 = Mon

        for window in windows {
            if window.weekdays.contains(currentWeekday) {
                if window.crossesMidnight {
                    if currentMinutes >= window.startMinutes || currentMinutes < window.endMinutes {
                        return true
                    }
                } else {
                    if currentMinutes >= window.startMinutes && currentMinutes < window.endMinutes {
                        return true
                    }
                }
            }
        }
        return false
    }

    func stopUsageMonitoring() {
        activityCenter.stopMonitoring([ScreenTimeStorage.usageActivityName])
        clearDefaultShield()
    }

    func stopFocusMonitoring() {
        let activitiesToStop = activityCenter.activities.filter { $0.rawValue.hasPrefix("marble.focus.") }
        activityCenter.stopMonitoring(Array(activitiesToStop))
        sharedDefaults?.set(false, forKey: ScreenTimeStorage.focusWindowActiveKey)
        sharedDefaults?.synchronize()
        clearFocusShield()
    }

    static func focusSchedule(
        startMinutes: Int,
        endMinutes: Int,
        weekday: FocusWeekday,
        calendar: Calendar = .current,
        timeZone: TimeZone = .current
    ) -> DeviceActivitySchedule? {
        guard
            (0..<(24 * 60)).contains(startMinutes),
            (0..<(24 * 60)).contains(endMinutes),
            startMinutes != endMinutes
        else {
            return nil
        }

        let crossesMidnight = endMinutes < startMinutes
        return DeviceActivitySchedule(
            intervalStart: dateComponents(
                weekday: weekday,
                minutesFromMidnight: startMinutes,
                calendar: calendar,
                timeZone: timeZone
            ),
            intervalEnd: dateComponents(
                weekday: crossesMidnight ? weekday.next : weekday,
                minutesFromMidnight: endMinutes,
                calendar: calendar,
                timeZone: timeZone
            ),
            repeats: true
        )
    }

    private static func focusActivityName(
        for weekday: FocusWeekday
    ) -> DeviceActivityName {
        DeviceActivityName("marble.focus.\(weekday.rawValue)")
    }

    private static func focusActivityName(
        for windowId: UUID,
        weekday: FocusWeekday
    ) -> DeviceActivityName {
        DeviceActivityName("marble.focus.\(windowId.uuidString).\(weekday.rawValue)")
    }

    private static func dateComponents(
        weekday: FocusWeekday,
        minutesFromMidnight: Int,
        calendar: Calendar,
        timeZone: TimeZone
    ) -> DateComponents {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = timeZone
        components.weekday = weekday.rawValue
        components.hour = minutesFromMidnight / 60
        components.minute = minutesFromMidnight % 60
        return components
    }

    private static func hasSelection(
        _ selection: FamilyActivitySelection
    ) -> Bool {
        !selection.applicationTokens.isEmpty
            || !selection.categoryTokens.isEmpty
            || !selection.webDomainTokens.isEmpty
    }

    private func applyDefaultShield(for selection: FamilyActivitySelection) {
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        let webDomains = selection.webDomainTokens

        defaultStore.shield.applications = applications.isEmpty ? nil : applications
        defaultStore.shield.applicationCategories = categories.isEmpty
            ? nil
            : .specific(categories)
        defaultStore.shield.webDomains = webDomains.isEmpty ? nil : webDomains
        defaultStore.shield.webDomainCategories = categories.isEmpty
            ? nil
            : .specific(categories)
    }

    private func clearDefaultShield() {
        defaultStore.shield.applications = nil
        defaultStore.shield.applicationCategories = nil
        defaultStore.shield.webDomains = nil
        defaultStore.shield.webDomainCategories = nil
    }

    private func clearFocusShield() {
        focusStore.shield.applications = nil
        focusStore.shield.applicationCategories = nil
        focusStore.shield.webDomains = nil
        focusStore.shield.webDomainCategories = nil
    }

    private func mapAuthorizationStatus(
        _ status: AuthorizationStatus
    ) -> ScreenTimePermissionStatus {
        #if compiler(>=6.3)
        if #available(iOS 26.4, *), status == .approvedWithDataAccess {
            return .approvedWithDataAccess
        }
        #endif

        switch status {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .approved: return .approved
        default: return .failed
        }
    }
}
