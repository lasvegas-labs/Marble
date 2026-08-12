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
    
    @Published public var hasAuthorization = false
    @Published public var selectionToDiscourage = FamilyActivitySelection()
    
    // Use the default store which is automatically shared with the app's extensions
    let store = ManagedSettingsStore()
    
    private init() {
        self.selectionToDiscourage = ScreenTimeService().loadSelection()
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
        } catch {
            print("Failed to authorize Family Controls: \(error)")
            hasAuthorization = false
        }
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
