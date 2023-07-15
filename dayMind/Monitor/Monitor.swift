import Foundation
import ManagedSettings
import DeviceActivity
import os.log

class Monitor: DeviceActivityMonitor {
    

    override func intervalDidStart(for activity: DeviceActivityName) {
        os_log("intervalDidStart 함수가 호출되었습니다.", type: .default)
        super.intervalDidStart(for: activity)

        let missions = MissionStorage.loadMissions()
        guard let mission = missions.first(where: { $0.id.uuidString == activity.rawValue }) else { return }
        let currentStoreName = ManagedSettingsStore.Name(rawValue: mission.currentStore)
        
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
            super.intervalDidEnd(for: activity)
            os_log("intervalDidEnd 함수가 호출되었습니다.", type: .default)

//            let missions = MissionStorage.loadMissions()
//            guard let mission = missions.first(where: { $0.id.uuidString == activity.rawValue }) else { return }
//            let currentStoreName = ManagedSettingsStore.Name(rawValue: mission.currentStore)
//            let selectedList = ManagedSettingsStore(named: currentStoreName)
//            selectedList.clearAllSettings()
        }
    }
