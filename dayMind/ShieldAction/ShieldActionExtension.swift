
import Foundation
import ManagedSettings
import os.log


// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    
    func secondaryAction() -> Bool {
        os_log("함수 호출됨", type: .default)
        let now = Date()
        let missions = MissionStorage.loadMissions()
        let missionStatusManager = MissionStatusManager.loadStatuses()
        let calendar = Calendar.current
        os_log("함수 2번", type: .default)
        
        for mission in missions {
            if let missionStatus = missionStatusManager?.status(for: mission.id), missionStatus == .inProgress {
                os_log("함수 3번", type: .default)
                
                // Create date components for now
                let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
                // Convert the nowComponents back into a Date
                let nowDate = calendar.date(from: nowComponents)!
                
                // Create date components for mission's selectedTime2
                let missionTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: mission.selectedTime2)
                // Convert the missionTimeComponents back into a Date
                let missionDate = calendar.date(from: missionTimeComponents)!
                
                if missionDate > nowDate {
                    missionStatusManager?.updateStatus(for: mission.id, to: .success)
                    os_log("함수 4번", type: .default)
                    
                    let currentStoreName = ManagedSettingsStore.Name(rawValue: mission.currentStore)
                    let selectedList = ManagedSettingsStore(named: currentStoreName)
                    selectedList.clearAllSettings()
                    os_log("함수 5번", type: .default)
                    
                    if let missionStatusManager = missionStatusManager {
                        MissionStatusManager.saveStatuses(statusManager: missionStatusManager)
                        os_log("함수 6번", type: .default)
                    }
                    return true
                }
            }
        }
        
        return false
    }
    
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(secondaryAction() ? .close : .none)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(secondaryAction() ? .close : .none)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(secondaryAction() ? .close : .none)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
}
