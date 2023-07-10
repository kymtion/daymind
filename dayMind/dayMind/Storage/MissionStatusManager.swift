
import Foundation
import SwiftUI

class MissionStatusManager: ObservableObject, Codable {
    private var missionStatuses: [UUID: MissionStatus]

    init() {
        self.missionStatuses = [:]
    }

    func status(for missionID: UUID) -> MissionStatus? {
        return missionStatuses[missionID]
    }

    func updateStatus(for missionID: UUID, to newStatus: MissionStatus) {
        missionStatuses[missionID] = newStatus
    }

    static func saveStatuses(statusManager: MissionStatusManager) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(statusManager)
            UserDefaults(suiteName: "group.kr.co.daymind.daymind")?.set(data, forKey: "missionStatuses")
        } catch {
            print("Error encoding mission statuses: \(error)")
        }
    }

    static func loadStatuses() -> MissionStatusManager? {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults(suiteName: "group.kr.co.daymind.daymind")?.data(forKey: "missionStatuses") {
            do {
                return try decoder.decode(MissionStatusManager.self, from: savedData)
            } catch {
                print("Error decoding mission statuses: \(error)")
            }
        }
        return nil
    }
}




enum MissionStatus: String, Codable {
    case beforeStart
    case inProgress
    case success
    case failure

    var description: String {
        switch self {
        case .beforeStart:
            return "대기중"
        case .inProgress:
            return "진행중"
        case .success:
            return "성공"
        case .failure:
            return "실패"
        }
    }

    var color: Color {
        switch self {
        case .beforeStart:
            return Color.gray
        case .inProgress:
            return Color.blue
        case .success:
            return Color.green
        case .failure:
            return Color.red
        }
    }
}
