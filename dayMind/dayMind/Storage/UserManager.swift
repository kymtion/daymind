//
//import Foundation
//import FirebaseFirestore
//
//
//struct User: Codable {
//    var uid: String
//    var balance: Int
//    var missions: [String] // 미션 ID 목록
//}
//
//
//class UserManager {
//    static let shared = UserManager()
//    private let db = Firestore.firestore()
//
//    // 사용자 정보 저장
//    func saveUser(user: User) {
//        do {
//            let data = try JSONEncoder().encode(user)
//            guard let userData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
//                throw NSError()
//            }
//            db.collection("users").document(user.uid).setData(userData)
//        } catch let error {
//            print("Error writing user to Firestore: \(error)")
//        }
//    }
//
//    // 사용자 정보 로드
//    func loadUser(userId: String, completion: @escaping (User?) -> Void) {
//        db.collection("users").document(userId).getDocument { (snapshot, error) in
//            guard let snapshot = snapshot, let data = snapshot.data(),
//                  let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
//                  let user = try? JSONDecoder().decode(User.self, from: jsonData) else {
//                print("Error loading user: \(error?.localizedDescription ?? "")")
//                completion(nil)
//                return
//            }
//            completion(user)
//        }
//    }
//
//    // 사용자 미션 로드 (위에서 작성한 로직)
//    func loadUserMissions(userId: String, completion: @escaping ([FirestoreMission]) -> Void) {
//        let userDocument = Firestore.firestore().collection("users").document(userId)
//        userDocument.getDocument { (userSnapshot, error) in
//            guard let userSnapshot = userSnapshot, let missionIds = userSnapshot.data()?["missions"] as? [String] else {
//                print("Error loading user missions: \(error?.localizedDescription ?? "")")
//                completion([])
//                return
//            }
//
//            let group = DispatchGroup()
//            var userMissions: [FirestoreMission] = []
//
//            for missionId in missionIds {
//                group.enter()
//                let missionDocument = Firestore.firestore().collection("missions").document(missionId)
//                missionDocument.getDocument { (missionSnapshot, error) in
//                    if let missionSnapshot = missionSnapshot, let missionData = missionSnapshot.data(),
//                       let mission = try? FirestoreMission(from: missionData) {
//                        userMissions.append(mission)
//                    }
//                    group.leave()
//                }
//            }
//
//            group.notify(queue: .main) {
//                completion(userMissions)
//            }
//        }
//    }
//
//}
