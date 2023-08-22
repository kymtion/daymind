
import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User: Codable {
    var userId: String
    var balance: Int
    var nickname: String
}

class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    
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
                     let user = try? JSONDecoder().decode(User.self, from: jsonData) else {
                   print("Error loading user: \(error?.localizedDescription ?? "")")
                   completion(nil)
                   return
               }
               completion(user)
           }
       }
}
