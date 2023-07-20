

import Foundation


struct MissionStorage: Identifiable, Codable {
    var selectedTime1: Date
    var selectedTime2: Date
    var currentStore: String
    var missionType: String
    var imageName: String
    let id: UUID
    
    init(selectedTime1: Date, selectedTime2: Date, currentStore: String,  missionType: String, imageName: String) {
        self.selectedTime1 = selectedTime1
        self.selectedTime2 = selectedTime2
        self.currentStore = currentStore
        self.missionType = missionType
        self.imageName = imageName
        self.id = UUID()
    }
    
    
    
    static func saveMissions(missions: [MissionStorage], userDefaultsManager: UserDefaultsManager) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(missions)
            UserDefaultsManager.shared.set(data, forKey: "missions")
        } catch {
            print("Error encoding missions: \(error)")
        }
    }
    
    static func loadMissions(userDefaultsManager: UserDefaultsManager) -> [MissionStorage] {
        let decoder = JSONDecoder()
        if let savedData = UserDefaultsManager.shared.data(forKey: "missions") {
            do {
                return try decoder.decode([MissionStorage].self, from: savedData)
            } catch {
                print("Error decoding missions: \(error)")
            }
        }
        return []
    }
}
