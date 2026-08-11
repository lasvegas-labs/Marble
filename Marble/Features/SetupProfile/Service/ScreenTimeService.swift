import DeviceActivity
import FamilyControls
import Foundation

enum ScreenTimeStorage {
    static let appGroupIdentifier = "group.com.lasvegas.MarbleSande"
    static let selectionKey = "screenTime.familyActivitySelection"
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
            let selection = try? JSONDecoder().decode(
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

        let data = try JSONEncoder().encode(selection)
        sharedDefaults.set(data, forKey: ScreenTimeStorage.selectionKey)
    }

    func clearSelection() {
        sharedDefaults?.removeObject(forKey: ScreenTimeStorage.selectionKey)
    }

    func configureFocusMonitoring(
        startMinutes: Int?,
        endMinutes: Int?,
        weekdays: Set<FocusWeekday>
    ) throws -> Bool {
        stopFocusMonitoring()

        guard
            let startMinutes,
            let endMinutes,
            startMinutes != endMinutes,
            !weekdays.isEmpty
        else {
            return false
        }

        let crossesMidnight = endMinutes < startMinutes

        do {
            for weekday in weekdays {
                let endWeekday = crossesMidnight ? weekday.next : weekday
                let schedule = DeviceActivitySchedule(
                    intervalStart: dateComponents(
                        weekday: weekday,
                        minutesFromMidnight: startMinutes
                    ),
                    intervalEnd: dateComponents(
                        weekday: endWeekday,
                        minutesFromMidnight: endMinutes
                    ),
                    repeats: true
                )

                try activityCenter.startMonitoring(
                    activityName(for: weekday),
                    during: schedule
                )
            }
            return true
        } catch {
            stopFocusMonitoring()
            throw error
        }
    }

    func stopFocusMonitoring() {
        activityCenter.stopMonitoring(
            FocusWeekday.allCases.map(activityName(for:))
        )
    }

    private func activityName(for weekday: FocusWeekday) -> DeviceActivityName {
        DeviceActivityName("marble.focus.\(weekday.rawValue)")
    }

    private func dateComponents(
        weekday: FocusWeekday,
        minutesFromMidnight: Int
    ) -> DateComponents {
        var components = DateComponents()
        components.calendar = .current
        components.timeZone = .current
        components.weekday = weekday.rawValue
        components.hour = minutesFromMidnight / 60
        components.minute = minutesFromMidnight % 60
        return components
    }

    private func mapAuthorizationStatus(
        _ status: AuthorizationStatus
    ) -> ScreenTimePermissionStatus {
        #if swift(>=5.10)
        if #available(iOS 17.4, *), status == .approvedWithDataAccess {
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
