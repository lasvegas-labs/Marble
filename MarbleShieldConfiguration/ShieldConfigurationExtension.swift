import ManagedSettings
import ManagedSettingsUI
import SwiftUI

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
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialLight,
            backgroundColor: .white,
            // We would set the icon here if we had the image data. For now, no icon, or we can use a system image if possible.
            // icon: UIImage(named: "OrbIcon"),
            title: ShieldConfiguration.Label(text: "Are you sure to continue?", color: .black),
            subtitle: ShieldConfiguration.Label(text: "I have some fun and useful recommendation for you", color: .gray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Show The Recommendation", color: .black),
            primaryButtonBackgroundColor: UIColor(white: 0.95, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Continue Scrolling", color: .gray)
        )
    }
}
