

import Foundation
import SwiftUI

struct AppGroupMission: Identifiable, Codable {
    var id: UUID
    var selectedTime1: Date
    var selectedTime2: Date
    var currentStore: String
    var missionType: String
    var imageName: String
    var missionStatus: MissionStatus
    var actualAmount: Int
    var userId: String
    
    static func saveMissionAppGroup(missions: [AppGroupMission]) {
        let userDefaults = UserDefaults(suiteName: "group.kr.co.daymind.daymind")
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(missions)
            userDefaults?.set(data, forKey: "missions")
        } catch let error {
            print("Error encoding missions: \(error)")
        }
    }
    
    static func loadMissionAppGroup() -> [AppGroupMission] {
        let userDefaults = UserDefaults(suiteName: "group.kr.co.daymind.daymind")
        do {
            let decoder = JSONDecoder()
            if let data = userDefaults?.data(forKey: "missions") {
                let missions = try decoder.decode([AppGroupMission].self, from: data)
                return missions
            }
        } catch let error {
            print("Error decoding missions: \(error)")
        }
        return []
    }
}
