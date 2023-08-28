import Foundation
import SwiftUI
import FirebaseAuth
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import FirebaseFunctions
import FirebaseFirestore


class LoginViewModel: NSObject, ObservableObject {
    
    @Published var isLoggedin: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: Error? = nil
    @Published var isLoading: Bool = false
    @Published var isSigningUp: Bool = false
    
 
    var handle: AuthStateDidChangeListenerHandle?
    
    
    override init() {
        super.init()
               attachAuthListener()
           }
    
    deinit {
           detachAuthListener()
       }
    
    var functions = Functions.functions()
    
    func loginWithKakao(completion: @escaping (Error?) -> Void) {
        isLoading = true
           if (UserApi.isKakaoTalkLoginAvailable()) {
               UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                   if let error = error {
                       completion(error)
                       return
                   }
                   print("loginWithKakaoTalk() success.")
                   self.exchangeKakaoCode(accessToken: oauthToken?.accessToken, completion: completion)
               }
           } else {
               UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                   if let error = error {
                       completion(error)
                       return
                   }
                   print("loginWithKakaoAccount() success.")
                   self.exchangeKakaoCode(accessToken: oauthToken?.accessToken, completion: completion)
               }
           }
       }

    
    func exchangeKakaoCode(accessToken: String?, completion: @escaping (Error?) -> Void) {
        guard let token = accessToken else {
            completion(NSError(domain: "LoginViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token is missing"]))
            isLoading = false // 로딩 상태 업데이트
            return
        }
        
        let data: [String: Any] = ["access_token": token]
        functions.httpsCallable("exchangeKakaoCode").call(data) { (result, error) in
            if let error = error as NSError? {
                completion(error)
                return
            }
            if let firebaseToken = (result?.data as? [String: Any])?["firebase_token"] as? String {
                print("Received Firebase token: \(firebaseToken)")
                
                // Firebase 로그인
                Auth.auth().signIn(withCustomToken: firebaseToken) { (authResult, error) in
                    if let error = error {
                        completion(error)
                        self.isLoading = false // 로딩 상태 업데이트
                        return
                    }
                    
                    // 로그인이 성공하면, 여기서 이후 처리를 진행합니다.
                    print("Signed in to Firebase successfully")
                    
                    // Add your Firebase ID token fetching code here
                    let currentUser = Auth.auth().currentUser
                    currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                        if let error = error {
                            completion(error)
                            self.isLoading = false // 로딩 상태 업데이트
                            return
                        }
                        
                        // Create user account
                        if let userId = authResult?.user.uid {
                            self.createUserAccount(userId: userId, completion: completion)
                            self.isLoading = false // 로딩 상태 업데이트
                        }
                    }
                }
            }
        }
    }
    
    //     로그인할때 계정 데이터를 파이어스토어에 저장해줌 단, 데이터가 기존에 있다면 저장하지 않음
        private func createUserAccount(userId: String, completion: @escaping (Error?) -> Void) {
            let userCollection = Firestore.firestore().collection("users")

            // 영어 소문자 3자리와 숫자 5자리로 닉네임을 생성합니다.
            let letters = "abcdefghijklmnopqrstuvwxyz"
            let numbers = "0123456789"
            let letterPart = String((0..<3).map { _ in letters.randomElement()! })
            let numberPart = String((0..<5).map { _ in numbers.randomElement()! })
            let nickname = letterPart + numberPart

            let userDocument = userCollection.document(userId)
            userDocument.getDocument { (documentSnapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }

                // 사용자 데이터가 존재하지 않을 경우 생성
                    if let documentSnapshot = documentSnapshot, !documentSnapshot.exists {
                        // 초기 FCM 토큰을 null로 설정
                        let initialUser = User(userId: userId, balance: 0, nickname: nickname, fcmToken: "Not set")
                        UserManager.shared.saveUser(user: initialUser)
                        completion(nil)
                    } else {
                        print("User already exists, no need to create")
                        completion(nil)
                    }
                }
            }



    
    
    // 사용자의 인증상태 변화를 감지하는 역할
    func attachAuthListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if !self.isSigningUp {  // <-- 상태 변수를 확인
                self.isLoggedin = user != nil
            }
        }
    }
    
//     이 함수는 리스너를 종료하는 함수로 메모리 누수를 방지함
    func detachAuthListener() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func loginWithEmail(completion: @escaping (Error?) -> Void) {
        isLoading = true
           Auth.auth().signIn(withEmail: self.email, password: self.password) { authResult, error in
               self.isLoading = false
               if let error = error {
                   completion(error)
                   return
               }
               print("Signed in to Firebase successfully")
               
               // Create user account
               if let userId = authResult?.user.uid {
                   self.createUserAccount(userId: userId, completion: completion)
               }
           }
       }
    
    func signUpWithEmail(completion: @escaping (Error?) -> Void) {
        isLoading = true
        isSigningUp = true
        Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.isSigningUp = false
                if let error = error {
                    completion(error)
                    return
                }
                
                // 회원가입 성공 후 자동 로그인을 방지하기 위해 로그아웃
                do {
                    try Auth.auth().signOut()
                    self.isLoggedin = false
                    self.error = nil
                } catch let signOutError {
                    print("Error signing out: \(signOutError)")
                    completion(signOutError)
                    return
                }
                completion(nil)
            }
        }
    }
    

    
    
    func sendPasswordResetWithEmail(_ email: String, completion: @escaping (Error?) -> Void) {
           Auth.auth().sendPasswordReset(withEmail: email) { error in
               completion(error)
           }
       }
   }

