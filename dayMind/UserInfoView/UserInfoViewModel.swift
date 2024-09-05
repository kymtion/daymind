import Foundation
import FirebaseAuth
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import Alamofire
import FirebaseFirestore

class UserInfoViewModel: ObservableObject {
    @Published var email = ""
    @Published var uid: String = ""
    @Published var nickname: String = ""
    @Published var missions: [FirestoreMission] = []
    @Published var balance: Int = 0
    @Published var transactions: [Transaction] = []
    
    
    private let db = Firestore.firestore()
    var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                self.uid = user.uid
                self.email = user.email ?? ""
                self.loadNickname()
            } else {
                self.uid = ""
                self.email = ""
                self.nickname = ""
            }
        }
        
        // UserManager에서 사용자 정보 변경을 감지
        UserManager.shared.listenForUserChanges { user in
            if let user = user {
                self.uid = user.userId
                self.nickname = user.nickname
                self.balance = user.balance
            }
        }
        
        
        FirestoreMission.listenForChanges { missions in
            self.missions = missions
        }
        
        loadUserBalance()
        
        listenForTransactions { transactions in // 이 부분을 추가
            self.transactions = transactions
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func loadNickname() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userDocument = db.collection("users").document(userId)
        userDocument.getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists, let data = document.data() {
                self.nickname = data["nickname"] as? String ?? "" // 닉네임을 로드하고 업데이트합니다.
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
        
        let user = User(userId: userId, balance: newBalance, nickname: self.nickname)
        UserManager.shared.saveUser(user: user)
        self.balance = newBalance // 뷰 모델의 잔액 업데이트
    }
    
    // 실패, 성공, 취소를 제외한 모든 미션의 예치금 합산 -> 현재의 예치금 총액을 알 수 있음
    func calculateOtherAmounts() -> Int {
        var otherAmount = 0
        
        for mission in missions {
            if mission.missionStatus != .success && mission.missionStatus != .failure  && mission.missionStatus != .canceled {
                otherAmount += mission.actualAmount
            }
        }
        
        return otherAmount
    }
    
    // 실패, 성공, 취소 미션들의 예치금 합산 -> 총 환급 금액과 벌금 총액을 계산해줌
    func calculateAmounts() -> (successAmount: Int, failureAmount: Int, canceledAmount: Int) {
        var successAmount = 0
        var failureAmount = 0
        var canceledAmount = 0
        
        for mission in missions {
            if mission.missionStatus == .success {
                successAmount += mission.actualAmount
            } else if mission.missionStatus == .failure {
                failureAmount += mission.actualAmount
            } else if mission.missionStatus == .canceled {
                canceledAmount += mission.actualAmount
            }
        }
        
        return (successAmount, failureAmount, canceledAmount)
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
        dateFormatter.dateFormat = "yyyy. MM.dd"
        let calendar = Calendar.current
        
        for mission in missions {
            if mission.missionStatus == .success || mission.missionStatus == .failure || mission.missionStatus == .canceled {
                let dateWithoutTime = calendar.startOfDay(for: mission.selectedTime2) // 시간 구성 요소를 제거합니다.
                let dateString = dateFormatter.string(from: dateWithoutTime)
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
            self.nickname = ""
        } catch let signOutError {
            return signOutError
        }
        return nil
    }
    
    enum AuthError: Error {
        case userNotLoggedIn
        case wrongPassword
    }
    
    
    
    
    
    // 닉네임 변경 함수
    func updateProfile(nickname: String, completion: @escaping (Error?) -> Void) {
        // Firestore의 users 컬렉션 참조
        let usersCollection = Firestore.firestore().collection("users")
        
        // nickname이 겹치는 문서가 있는지 확인
        usersCollection.whereField("nickname", isEqualTo: nickname).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            // 겹치는 닉네임이 있다면 오류 반환
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                completion(NSError(domain: "updateProfile", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미 사용 중인 닉네임입니다."]))
                return
            }
            
            // 현재 로그인한 사용자의 UID
            guard let userId = Auth.auth().currentUser?.uid else {
                completion(NSError(domain: "updateProfile", code: -2, userInfo: [NSLocalizedDescriptionKey: "현재 로그인한 사용자가 없습니다."]))
                return
            }
            
            // 닉네임 업데이트
            usersCollection.document(userId).updateData(["nickname": nickname]) { error in
                if let error = error {
                    completion(error)
                } else {
                    // 성공적으로 업데이트 완료
                    completion(nil)
                }
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
        // 파이어베이스 계정 삭제 전에 리스너 제거
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        // 파이어베이스 계정 삭제
        Auth.auth().currentUser?.delete(completion: completion)
    }
    
    //카카오, 파이어베이스 모두 적용되는 로그아웃
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

