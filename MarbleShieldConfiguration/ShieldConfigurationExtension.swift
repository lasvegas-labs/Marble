import ManagedSettings
import ManagedSettingsUI
import UIKit

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
        // Load the icon from the extension's own asset catalog and resize to 228x228
        let shieldIcon = loadAndResizeIcon(named: "ShieldIcon", size: CGSize(width: 228, height: 228))
        
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
    }
    
    private func loadAndResizeIcon(named name: String, size: CGSize) -> UIImage? {
        guard let original = UIImage(named: name) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            original.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
