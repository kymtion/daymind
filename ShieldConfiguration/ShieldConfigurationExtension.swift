import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .light,
            backgroundColor: .white,
            subtitle: ShieldConfiguration.Label(text: "약속한 시간이 지나고 '미션완료' 버튼을 누르면 인증 완료! 앱 차단이 해제됩니다.", color: .black),
            primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
            secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        return ShieldConfiguration(
                        backgroundBlurStyle: .light,
                        backgroundColor: .white,
                        subtitle: ShieldConfiguration.Label(text: "약속한 시간이 지나고 '미션완료' 버튼을 누르면 인증 완료! 앱 차단이 해제됩니다.", color: .black),
                        primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
                        secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        return ShieldConfiguration(
                        backgroundBlurStyle: .light,
                        backgroundColor: .white,
                        subtitle: ShieldConfiguration.Label(text: "약속한 시간이 지나고 '미션완료' 버튼을 누르면 인증 완료! 앱 차단이 해제됩니다.", color: .black),
                        primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
                        secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        return ShieldConfiguration(
                        backgroundBlurStyle: .light,
                        backgroundColor: .white,
                        subtitle: ShieldConfiguration.Label(text: "약속한 시간이 지나고 '미션완료' 버튼을 누르면 인증 완료! 앱 차단이 해제됩니다.", color: .black),
                        primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
                        secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }
}
