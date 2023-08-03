import Foundation
import SwiftUI
import FirebaseFirestore

struct FirestoreMission: Identifiable, Codable {
    var id: UUID
    var selectedTime1: Date
    var selectedTime2: Date
    var currentStore: String
    var missionType: String
    var imageName: String
    var missionStatus: MissionStatus

  

    static let db = Firestore.firestore()
    
    //해당 코드는 Firestore에서 변경사항이 발생하면 변경된 최신 데이터를 앱그룹에 저장함
    static var missions: [FirestoreMission] = [] {
        didSet {
            AppGroupMission.saveMissionAppGroup(missions: missions.map { MissionTransformer.transform(firestoreMission: $0) })
        }
    }

    static func initializeMissions() {
        loadFirestoreMissions { loadedMissions in
            missions = loadedMissions
        }
    }

    static func saveFirestoreMission(mission: FirestoreMission) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(mission)
            guard let missionData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw NSError()
            }
            db.collection("missions").document(mission.id.uuidString).setData(missionData)
        } catch let error {
            print("Error writing mission to Firestore: \(error)")
        }
    }

    static func updateMissionStatus(missionId: UUID, newStatus: MissionStatus) {
        db.collection("missions").document(missionId.uuidString).updateData([
            "missionStatus": newStatus.rawValue
        ])
    }

    static func loadFirestoreMissions(completion: @escaping ([FirestoreMission]) -> Void) {
        db.collection("missions").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting missions: \(err)")
            } else {
                let decoder = JSONDecoder()
                let missions = querySnapshot?.documents.compactMap { document -> FirestoreMission? in
                    guard let data = try? JSONSerialization.data(withJSONObject: document.data(), options: []),
                          let mission = try? decoder.decode(FirestoreMission.self, from: data) else {
                        return nil
                    }
                    return mission
                }
                if let missions = missions {
                    self.missions = missions// 이렇게 하면 앱을 종료하진 않아도 데이터가 동기화 되는데 즉시시작할때는 여전히 유효하진 않음,
                }
                completion(missions ?? [])
            }
        }
    }
//이 함수는 Firestore 데이터베이스의 "missions" 컬렉션에 어떤 변화가 생기면 즉시 호출되므로, 앱이 Firestore 데이터베이스의 최신 상태를 실시간으로 반영하도록 할 수 있습니다.
//이 함수가 필요한 이유는 어드민 페이지에서 데이터를 변경할 경우 앱이 바로 알아차릴 수 있도록 도와줌!
    static func listenForChanges() {
        db.collection("missions").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            let missions = documents.compactMap { document -> FirestoreMission? in
                guard let data = try? JSONSerialization.data(withJSONObject: document.data(), options: []),
                      let mission = try? JSONDecoder().decode(FirestoreMission.self, from: data) else {
                    return nil
                }
                return mission
            }
            self.missions = missions
        }
    }
}
