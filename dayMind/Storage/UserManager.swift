
import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User: Codable {
    var userId: String
    var balance: Int
    var nickname: String
    var fcmToken: String?
    var deviceId: String?  // 디바이스 ID 필드 추가
    var notificationSettings: [String: Bool]?
}

class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    
    
    // FCM 토큰과 디바이스 ID를 함께 저장하는 함수
    func saveUserWithFCMTokenAndDeviceId(user: User, fcmToken: String, deviceId: String) {
        do {
            var data = try JSONEncoder().encode(user)
            guard var userData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw NSError()
            }
            // FCM 토큰과 디바이스 ID 추가
            userData["fcmToken"] = fcmToken
            userData["deviceId"] = deviceId
            db.collection("users").document(user.userId).setData(userData, merge: true)  // 기존 데이터와 병합하여 저장
        } catch let error {
            print("Error writing user with FCM Token and Device ID to Firestore: \(error)")
        }
    }
    
    func updateNotificationSettingsInFirestore(startNotificationEnabled: Bool, endNotificationEnabled: Bool, before10MinNotificationEnabled: Bool, firebasePushNotificationEnabled: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userId)
        
        let settings: [String: Bool] = [
            "startNotificationEnabled": startNotificationEnabled,
            "endNotificationEnabled": endNotificationEnabled,
            "before10MinNotificationEnabled": before10MinNotificationEnabled,
            "firebasePushNotificationEnabled": firebasePushNotificationEnabled
        ]
        
        userRef.setData(["notificationSettings": settings], merge: true) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    
    // 사용자 정보 저장
    func saveUser(user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            guard let userData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw NSError()
            }
            db.collection("users").document(user.userId).setData(userData)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
        }
    }
    
    // 현재 로그인한 사용자 정보 로드
    func loadUser(completion: @escaping (User?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user logged in.")
            completion(nil)
            return
        }
        
        db.collection("users").document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot, let data = snapshot.data(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
                  var user = try? JSONDecoder().decode(User.self, from: jsonData) else {
                print("Error loading user: \(error?.localizedDescription ?? "")")
                completion(nil)
                return
            }
            user.notificationSettings = data["notificationSettings"] as? [String: Bool]
            completion(user)
        }
    }
    
    func listenForUserChanges(completion: @escaping (User?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user logged in.")
            return
        }
        
        db.collection("users").document(userId)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error fetching user: \(error)")
                    completion(nil)
                    return
                }
                
                guard let document = documentSnapshot, let data = document.data(),
                      let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
                      let user = try? JSONDecoder().decode(User.self, from: jsonData) else {
                    print("Error decoding user data.")
                    completion(nil)
                    return
                }
                
                completion(user)
            }
    }
    
    
}
