import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .light,
            backgroundColor: .white,
//            icon: UIImage(systemName: "timer.circle.fill"), 나중에 앱 아이콘 디자인 된거 넣자! 마치 포레스트 앱 처럼!!
            primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
//            primaryButtonBackgroundColor: .blue,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        return ShieldConfiguration(
                        backgroundBlurStyle: .light,
                        backgroundColor: .white,
            //            icon: UIImage(systemName: "timer.circle.fill"),
                        primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
            //            primaryButtonBackgroundColor: .blue,
                        secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        return ShieldConfiguration(
                        backgroundBlurStyle: .light,
                        backgroundColor: .white,
            //            icon: UIImage(systemName: "timer.circle.fill"),
                        primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
            //            primaryButtonBackgroundColor: .blue,
                        secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        return ShieldConfiguration(
                        backgroundBlurStyle: .light,
                        backgroundColor: .white,
            //            icon: UIImage(systemName: "timer.circle.fill"), 나중에 앱 아이콘 디자인 된거 넣자!
                        primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
            //            primaryButtonBackgroundColor: .blue,
                        secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }
}
