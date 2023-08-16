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
    @Published var balance: Int = 0
    @Published var transactions: [Transaction] = []
    
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
                self.setDefaultNicknameIfNeeded() // 만약 사용자가 닉네임이 없다면 호출되어 닉네임을 만들어줌
            } else {
                self.uid = ""
                self.email = ""
                self.displayName = ""
            }
        }
        FirestoreMission.listenForChanges { missions in
               self.missions = missions
        }
        loadUserBalance()
        loadUserTransactions()
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func loadUserTransactions() {
            loadTransactions { loadedTransactions in
                if let loadedTransactions = loadedTransactions {
                    self.transactions = loadedTransactions
                }
            }
        }
    
    
    
    // 출금한 금액을 파이어스토어에 데이터로 저장하는 함수
    func saveWithdrawalTransaction(withdrawalAmount: Int) {
        if let userId = Auth.auth().currentUser?.uid {
            let transaction = Transaction(userId: userId, type: .withdrawal, amount: withdrawalAmount, date: Date())
            saveTransaction(transaction: transaction)
        }
    }
    
    // 잔액에서 출금 금액을 빼주고 저장해주는 함수
    func updateBalance(newBalance: Int) {
           guard let userId = Auth.auth().currentUser?.uid else {
               print("No current user logged in.")
               return
           }

           let user = User(uid: userId, balance: newBalance)
           UserManager.shared.saveUser(user: user)
           self.balance = newBalance // 뷰 모델의 잔액 업데이트
       }
    
    // 실패, 성공을 제외한 모든 미션의 예치금 합산
    func calculateOtherAmounts() -> Int {
        var otherAmount = 0
        
        for mission in missions {
            if mission.missionStatus != .success && mission.missionStatus != .failure {
                otherAmount += mission.actualAmount
            }
        }
        
        return otherAmount
    }
    
    // 실패, 성공 미션들의 예치금 합산 
        func calculateAmounts() -> (successAmount: Int, failureAmount: Int) {
            var successAmount = 0
            var failureAmount = 0
            
            for mission in missions {
                if mission.missionStatus == .success {
                    successAmount += mission.actualAmount
                } else if mission.missionStatus == .failure {
                    failureAmount += mission.actualAmount
                }
            }
            
            return (successAmount, failureAmount)
        }


    
    // 사용자 남은 잔액 정보 가져오기
    func loadUserBalance() {
        UserManager.shared.loadUser { user in
            if let user = user {
                self.balance = user.balance
            }
        }
    }
    
    // 사용자 남은 잔액 정보 업데이트
    func updateBalance(newBalance: Int, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(uid).updateData(["balance": newBalance]) { error in
            completion(error)
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
    
    
    
    // 닉네임 자동 생성
    func setDefaultNicknameIfNeeded() {
        if let user = Auth.auth().currentUser, (user.displayName == nil || user.displayName?.isEmpty == true) {
            // 닉네임이 없는 경우 자동으로 생성합니다.
            let randomNumber = Int.random(in: 100000..<1000000) // 100000부터 999999까지의 랜덤한 숫자
            let defaultNickname = "#\(randomNumber)" // 예: '#123456'
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = defaultNickname
            changeRequest.commitChanges { error in
                if let error = error {
                    print("닉네임 설정 중 에러 발생: \(error)")
                } else {
                    print("닉네임이 성공적으로 설정되었습니다: \(defaultNickname)")
                }
            }
        }
    }

    // 닉네임 변경 함수
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

