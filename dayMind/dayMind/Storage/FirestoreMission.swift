import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FirestoreMission: Identifiable, Codable {
    var id: UUID
    var selectedTime1: Date
    var selectedTime2: Date
    var currentStore: String
    var missionType: String
    var imageName: String
    var missionStatus: MissionStatus
    var actualAmount: Int
    var userId: String
    
    init(id: UUID, selectedTime1: Date, selectedTime2: Date, currentStore: String, missionType: String, imageName: String, missionStatus: MissionStatus, actualAmount: Int, userId: String) {
        self.id = id
        self.selectedTime1 = selectedTime1
        self.selectedTime2 = selectedTime2
        self.currentStore = currentStore
        self.missionType = missionType
        self.imageName = imageName
        self.missionStatus = missionStatus
        self.actualAmount = actualAmount
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case selectedTime1 = "selectedTime1" // Firestore 필드 이름과 일치해야 합니다.
        case selectedTime2 = "selectedTime2" // Firestore 필드 이름과 일치해야 합니다.
        case currentStore
        case missionType
        case imageName
        case missionStatus
        case actualAmount
        case userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let selectedTime1Milliseconds = try container.decode(Double.self, forKey: .selectedTime1)
        let selectedTime2Milliseconds = try container.decode(Double.self, forKey: .selectedTime2)
        selectedTime1 = Date(timeIntervalSince1970: selectedTime1Milliseconds / 1000)
        selectedTime2 = Date(timeIntervalSince1970: selectedTime2Milliseconds / 1000)
        currentStore = try container.decode(String.self, forKey: .currentStore)
        missionType = try container.decode(String.self, forKey: .missionType)
        imageName = try container.decode(String.self, forKey: .imageName)
        missionStatus = try container.decode(MissionStatus.self, forKey: .missionStatus)
        actualAmount = try container.decode(Int.self, forKey: .actualAmount)
        userId = try container.decode(String.self, forKey: .userId)
    }
    
    
    
    
    static let db = Firestore.firestore()
    
    //해당 코드는 Firestore에서 변경사항이 발생하면 변경된 최신 데이터를 앱그룹에 저장함
    static var missions: [FirestoreMission] = [] {
        didSet {
            AppGroupMission.saveMissionAppGroup(missions: missions.map { MissionTransformer.transform(firestoreMission: $0) })
        }
    }
    
    static func initializeMissions() {
        loadUserMissions { loadedMissions in
            missions = loadedMissions
        }
    }

    
    static func saveFirestoreMission(mission: FirestoreMission) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(mission)
            guard var missionData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw NSError()
            }
            
            // selectedTime1 및 selectedTime2를 밀리초로 변환합니다.
            missionData["selectedTime1"] = mission.selectedTime1.timeIntervalSince1970 * 1000
            missionData["selectedTime2"] = mission.selectedTime2.timeIntervalSince1970 * 1000
            
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
    
    static func loadUserMissions(completion: @escaping ([FirestoreMission]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user logged in.")
            completion([]) // 로그인되지 않은 사용자의 경우 빈 배열 반환
            return
        }

        db.collection("missions")
            .whereField("userId", isEqualTo: userId) // userId 필드를 기준으로 필터링
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting missions: \(err)")
                    completion([]) // 에러 발생 시 빈 배열 반환
                } else {
                    let decoder = JSONDecoder()
                    let missions = querySnapshot?.documents.compactMap { document -> FirestoreMission? in
                        guard let data = try? JSONSerialization.data(withJSONObject: document.data(), options: []),
                              let mission = try? decoder.decode(FirestoreMission.self, from: data) else {
                            return nil
                        }
                        return mission
                    }
                    completion(missions ?? [])
                }
            }
    }

    
    
    //이 함수는 Firestore 데이터베이스의 "missions" 컬렉션에 어떤 변화가 생기면 즉시 호출되므로, 앱이 Firestore 데이터베이스의 최신 상태를 실시간으로 반영하도록 할 수 있습니다.
    //이 함수가 필요한 이유는 어드민 페이지에서 데이터를 변경할 경우 앱이 바로 알아차릴 수 있도록 도와줌!
    static func listenForChanges(completion: @escaping ([FirestoreMission]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user logged in.")
            return
        }

        db.collection("missions")
            .whereField("userId", isEqualTo: userId) // userId 필드를 기준으로 필터링
            .addSnapshotListener { querySnapshot, error in
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
                completion(missions)
            }
    }


    
}
