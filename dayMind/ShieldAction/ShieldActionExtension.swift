
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
        var missions = AppGroupMission.loadMissionAppGroup()
        let calendar = Calendar.current
        os_log("함수 2번", type: .default)
        
        for (index, mission) in missions.enumerated() {
            if mission.missionStatus == .inProgress {
                os_log("함수 3번", type: .default)
                
                let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
                let nowDate = calendar.date(from: nowComponents)!
                
                let missionTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: mission.selectedTime2)
                let missionDate = calendar.date(from: missionTimeComponents)!
                
                if missionDate > nowDate { // 테스트하고 원래대로 < 로 바꿔야함
                    missions[index].missionStatus = .verificationCompleted
                    os_log("함수 4번", type: .default)
                    AppGroupMission.saveMissionAppGroup(missions: missions)
                    os_log("함수 6번", type: .default)
                    
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
