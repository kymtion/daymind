import Foundation
import SwiftUI
import FirebaseAuth
import Combine
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import FirebaseFunctions

class LoginViewModel: NSObject, ObservableObject {
    
    @Published var isLoggedin: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var displayName: String = ""
    @Published var error: Error? = nil
    
    var logInWithCustomTokenSubject = PassthroughSubject<String, Never>()
    var logInSubject = PassthroughSubject<Void, Never>()
    var signUpSubject = PassthroughSubject<Void, Never>()
    var sendPasswordResetSubject = PassthroughSubject<String, Never>()
    var handle: AuthStateDidChangeListenerHandle?
    var cancellables = Set<AnyCancellable>()
    
    
    
    override init() {
        super.init()
        
        logInSubject
                   .flatMap { [unowned self] _ in self.loginWithKakao() }
                   .sink { completion in
                       switch completion {
                       case .failure(let error):
                           print("Error occurred: \(error)")
                           self.error = error
                       case .finished:
                           print("Login process completed")
                       }
                   } receiveValue: { _ in }
                   .store(in: &cancellables)
               
               signUpSubject
                   .flatMap { [unowned self] _ in self.signUpWithEmail() }
                   .sink { completion in
                       switch completion {
                       case .failure(let error):
                           print("Error occurred: \(error)")
                           self.error = error
                       case .finished:
                           print("SignUp process completed")
                       }
                   } receiveValue: { _ in }
                   .store(in: &cancellables)
               
               sendPasswordResetSubject
                   .flatMap { [unowned self] in self.sendPasswordResetWithEmail($0) }
                   .sink { completion in
                       switch completion {
                       case .failure(let error):
                           print("Error occurred: \(error)")
                           self.error = error
                       case .finished:
                           print("Password Reset process completed")
                       }
                   } receiveValue: { _ in }
                   .store(in: &cancellables)
               
               attachAuthListener()
           }

    
    var functions = Functions.functions()
    
    func loginWithKakao() -> Future<Void, Error> {
        return Future { promise in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        print("loginWithKakaoTalk() success.")
                        self.exchangeKakaoCode(accessToken: oauthToken?.accessToken)
                        promise(.success(()))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        print("loginWithKakaoAccount() success.")
                        self.exchangeKakaoCode(accessToken: oauthToken?.accessToken)
                        promise(.success(()))
                    }
                }
            }
        }
    }
    
    func exchangeKakaoCode(accessToken: String?) {
        guard let token = accessToken else {
            print("Access token is missing")
            return
        }
        
        let data: [String: Any] = ["access_token": token]
        functions.httpsCallable("exchangeKakaoCode").call(data) { (result, error) in
            if let error = error as NSError? {
                print("An error occurred엥???: \(error.localizedDescription)")
                return
            }
            if let firebaseToken = (result?.data as? [String: Any])?["firebase_token"] as? String {
                print("Received Firebase token: \(firebaseToken)")
                
                // Firebase 로그인
                Auth.auth().signIn(withCustomToken: firebaseToken) { (authResult, error) in
                    if let error = error {
                        print("Error signing in with Firebase: \(error.localizedDescription)")
                        return
                    }
                    
                    // 로그인이 성공하면, 여기서 이후 처리를 진행합니다.
                    print("Signed in to Firebase successfully")
                    
                    // Add your Firebase ID token fetching code here
                    let currentUser = Auth.auth().currentUser
                    currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                        if let error = error {
                            // Handle error
                            print("Error getting ID token: \(error)")
                            return
                        }
                        
                        // Send token to your backend via HTTPS
                        // ...
                    }
                }
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
    
    func loginWithEmail() -> Future<Void, Error> {
            return Future { promise in
                Auth.auth().signIn(withEmail: self.email, password: self.password) { authResult, error in
                    if let error = error {
                        print("Error signing in with Firebase: \(error.localizedDescription)")
                        promise(.failure(error))
                    } else {
                        print("Signed in to Firebase successfully")
                        promise(.success(()))
                    }
                }
            }
        }
    
    func signUpWithEmail() -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "LoginViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self not available"])))
                return
            }
            Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    self.isLoggedin = true
                    self.error = nil
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.displayName
                    changeRequest?.commitChanges { (error) in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            print("User display name updated")
                            promise(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    func sendPasswordResetWithEmail(_ email: String) -> Future<Void, Error> {
        return Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
}
