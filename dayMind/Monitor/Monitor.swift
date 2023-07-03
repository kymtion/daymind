
import Foundation
import ManagedSettings
import DeviceActivity

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class Monitor: DeviceActivityMonitor {

    override func intervalDidStart(for activity: DeviceActivityName) {
        print("intervalDidStart 함수가 호출되었습니다.")
        super.intervalDidStart(for: activity)

        let missions = MissionStorage.loadMissions()
        guard let latestMission = missions.last else { return }
        let currentStoreName = ManagedSettingsStore.Name(rawValue: latestMission.currentStore)
        
        let managedSettings = ManagedSettings.loadManagedSettings()
        if let activitySelection = managedSettings[currentStoreName] {
            
            let selectedAppTokens = activitySelection.applicationTokens
            let selectedWebDomainTokens = activitySelection.webDomainTokens

            let selectedList = ManagedSettingsStore(named: currentStoreName)
            selectedList.shield.applicationCategories = .all(except: selectedAppTokens)
            selectedList.shield.webDomainCategories = .all(except: selectedWebDomainTokens)
        }
    }


        override func intervalDidEnd(for activity: DeviceActivityName) {
            print("intervalDidEnd 함수가 호출되었습니다.")
            super.intervalDidEnd(for: activity)

            let missions = MissionStorage.loadMissions()
            guard let latestMission = missions.last else { return }
            let currentStoreName = ManagedSettingsStore.Name(rawValue: latestMission.currentStore)
            let selectedList = ManagedSettingsStore(named: currentStoreName)
            selectedList.clearAllSettings()
        }
    }
