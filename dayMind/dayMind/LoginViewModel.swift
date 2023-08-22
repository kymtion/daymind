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
    @Published var displayName: String = ""
    @Published var error: Error? = nil
    @Published var isLoading: Bool = false
    
 
    var handle: AuthStateDidChangeListenerHandle?
    
    
    override init() {
        super.init()
               attachAuthListener()
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
                        if let uid = authResult?.user.uid {
                            self.createUserAccount(uid: uid, completion: completion)
                            self.isLoading = false // 로딩 상태 업데이트
                        }
                    }
                }
            }
        }
    }
    
    // 로그인할때 계정 데이터를 파이어스토어에 저장해줌 단, 데이터가 기존에 있다면 저장하지 않음
    private func createUserAccount(uid: String, completion: @escaping (Error?) -> Void) {
           let userDocument = Firestore.firestore().collection("users").document(uid)
           userDocument.getDocument { (documentSnapshot, error) in
               if let error = error {
                   completion(error)
                   return
               }
               
               // 사용자 데이터가 존재하지 않을 경우 생성
               if let documentSnapshot = documentSnapshot, !documentSnapshot.exists {
                   let initialUser = User(uid: uid, balance: 0)
                   UserManager.shared.saveUser(user: initialUser)
               } else {
                   print("User already exists, no need to create")
                   completion(nil)
               }
           }
       }

    
    //----------------------------------------------------------------------------------------------------------------------------------------파이어베이스 로그인 부분
    
    func attachAuthListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            self.isLoggedin = user != nil
        }
    }
    
    
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
               if let uid = authResult?.user.uid {
                   self.createUserAccount(uid: uid, completion: completion)
               }
           }
       }
    
    func signUpWithEmail(completion: @escaping (Error?) -> Void) {
        isLoading = true
           Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, error in
               self.isLoading = false // 로딩 상태 업데이트
               if let error = error {
                   completion(error)
                   return
               }
               self.isLoggedin = true
               self.error = nil
               let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
               changeRequest?.displayName = self.displayName
               changeRequest?.commitChanges { (error) in
                   completion(error)
               }
           }
       }
    
    func sendPasswordResetWithEmail(_ email: String, completion: @escaping (Error?) -> Void) {
           Auth.auth().sendPasswordReset(withEmail: email) { error in
               completion(error)
           }
       }
   }

