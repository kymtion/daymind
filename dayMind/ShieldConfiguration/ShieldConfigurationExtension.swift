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
            subtitle: ShieldConfiguration.Label(text: "dayMind 앱을 완전히 종료 후 '미션완료' 버튼을 누르세요", color: .black),
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
                        subtitle: ShieldConfiguration.Label(text: "dayMind 앱을 완전히 종료 후 '미션완료' 버튼을 누르세요", color: .black),
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
                        subtitle: ShieldConfiguration.Label(text: "dayMind 앱을 완전히 종료 후 '미션완료' 버튼을 누르세요", color: .black),
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
                        subtitle: ShieldConfiguration.Label(text: "dayMind 앱을 완전히 종료 후 '미션완료' 버튼을 누르세요", color: .black),
                        primaryButtonLabel: ShieldConfiguration.Label(text: "미션 완료", color: .white),
            //            primaryButtonBackgroundColor: .blue,
                        secondaryButtonLabel: ShieldConfiguration.Label(text: "닫기", color: .darkGray)
        )
    }
}
