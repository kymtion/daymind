import Foundation
import FirebaseAuth
import Combine
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import Alamofire
import FirebaseFirestore

class UserInfoViewModel: ObservableObject {
    @Published var email = ""
    @Published var uid: String = ""
    @Published var displayName: String = ""
    @Published var missions: [FirestoreMission] = []
    
    private let db = Firestore.firestore()
    var handle: AuthStateDidChangeListenerHandle?
    var cancellables = Set<AnyCancellable>()
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                self.uid = user.uid
                self.email = user.email ?? ""
                self.displayName = user.displayName ?? ""
            } else {
                self.uid = ""
                self.email = ""
                self.displayName = ""
            }
        }
        FirestoreMission.loadFirestoreMissions { missions in
            self.missions = missions
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // 필터링, 그룹핑 및 정렬 작업을 수행하는 메소드
    func getGroupedMissions() -> [String: [FirestoreMission]] {
        
        var groupedMissions: [String: [FirestoreMission]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM"
        
        for mission in missions {
                   if mission.missionStatus == .success || mission.missionStatus == .failure {
                       let dateString = dateFormatter.string(from: mission.selectedTime2)
                       if groupedMissions[dateString] == nil {
                           groupedMissions[dateString] = []
                       }
                       groupedMissions[dateString]?.append(mission)
                   }
               }
               
               for (date, missions) in groupedMissions {
                   groupedMissions[date] = missions.sorted { $0.selectedTime2 > $1.selectedTime2 }
               }
               
               return groupedMissions
           }
    
    func signOut() -> Error? {
        do {
            try Auth.auth().signOut()
            self.uid = ""
            self.email = ""
            self.displayName = ""
        } catch let signOutError {
            return signOutError
        }
        return nil
    }
    
    enum AuthError: Error {
        case userNotLoggedIn
        case wrongPassword
    }
    func updateProfile(userName: String, completion: @escaping (Error?) -> Void) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = userName
        changeRequest?.commitChanges { error in
            if let error = error {
                completion(error)
            } else {
                // Add this line
                self.displayName = userName
                completion(nil)
            }
        }
    }
    
    func reauthenticate(currentPassword: String, completion: @escaping (Error?) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            completion(AuthError.userNotLoggedIn)
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                print("Reauthentication error: \(error.localizedDescription)") // Add this line
                completion(AuthError.wrongPassword)
            } else {
                completion(nil)
            }
        }
    }
    func sendEmailVerification(completion: @escaping (Error?) -> Void) {
        Auth.auth().currentUser?.sendEmailVerification { error in
            completion(error)
        }
    }
    
    func updatePassword(to password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: completion)
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        Auth.auth().currentUser?.delete(completion: completion)
    }
    //카카오 로그아웃 오후 9시 50분
    func logout() {
        // 현재 파이어베이스에 로그인된 사용자가 있는지 확인합니다.
        if let _ = Auth.auth().currentUser {
            do {
                // 로그인된 사용자가 있다면 파이어베이스에서 로그아웃합니다.
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error)")
            }
        }

        // 카카오 로그인 사용자의 로그아웃 처리를 수행합니다.
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.logout {(error) in
                if let error = error {
                    print("Kakao Logout Failed: \(error)")
                } else {
                    print("Kakao Logout Successful")
                }
            }
        }
    }
}

