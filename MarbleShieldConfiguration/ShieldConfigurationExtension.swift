import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

public enum MarbleShieldState: String, Codable {
    case friction
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

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration()
    }
    
    private func createShieldConfiguration() -> ShieldConfiguration {
        let shieldIcon = loadAndResizeIcon(named: "ShieldIcon", size: CGSize(width: 228, height: 228))
        let state = ShieldStateManager.shared.currentState
        
        switch state {
        case .friction:
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterialLight,
                backgroundColor: .white,
                icon: shieldIcon,
                title: ShieldConfiguration.Label(text: "Are you sure to continue?", color: .black),
                subtitle: ShieldConfiguration.Label(text: "I have some fun and useful recommendation for you", color: .gray),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Show The Recommendation", color: .black),
                primaryButtonBackgroundColor: UIColor(white: 0.95, alpha: 1.0),
                secondaryButtonLabel: ShieldConfiguration.Label(text: "Continue Scrolling", color: .gray)
            )
            
        case .waitingForNotification:
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterialLight,
                backgroundColor: .white,
                icon: shieldIcon,
                title: ShieldConfiguration.Label(text: "Click The Notification Above", color: .black),
                subtitle: ShieldConfiguration.Label(text: "To get the activity recommendations", color: .gray),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Didn’t See The Notifications", color: .black),
                primaryButtonBackgroundColor: UIColor(white: 0.95, alpha: 1.0),
                secondaryButtonLabel: nil
            )
            
        case .focusActive:
            return ShieldConfiguration(
                backgroundBlurStyle: .systemMaterialLight,
                backgroundColor: .white,
                icon: shieldIcon,
                title: ShieldConfiguration.Label(text: "Is Your 'Do Not Disturb' On?", color: .black),
                subtitle: ShieldConfiguration.Label(text: "Your notifications may not pop up while Focus is on. Try to turn it off or access the notification via Notification Center.", color: .gray),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Try Again", color: .black),
                primaryButtonBackgroundColor: UIColor(white: 0.95, alpha: 1.0),
                secondaryButtonLabel: nil
            )
        }
    }
    
    private func loadAndResizeIcon(named name: String, size: CGSize) -> UIImage? {
        guard let original = UIImage(named: name) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            original.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
