
import Foundation
import ManagedSettingsUI
import ManagedSettings
import UIKit


class CustomShieldConfigurationDataSource: ShieldConfigurationDataSource {
    
    let vm: MissionViewModel
        init(vm: MissionViewModel) {
            self.vm = vm
        }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // use application.bundleIdentifier to create a custom ShieldConfiguration
        let title = ShieldConfiguration.Label(text: "Shielded App", color: UIColor.white)
        let subtitle = ShieldConfiguration.Label(text: "This app is shielded due to the defined settings", color: UIColor.white)
        let configuration = ShieldConfiguration(backgroundBlurStyle: .systemThinMaterialDark,
                                                backgroundColor: UIColor.black,
                                                icon: UIImage(systemName: "lock.fill"),
                                                title: title,
                                                subtitle: subtitle,
                                                primaryButtonLabel: title,
                                                primaryButtonBackgroundColor: UIColor.systemBlue,
                                                secondaryButtonLabel: nil)
        return configuration
    }
}
