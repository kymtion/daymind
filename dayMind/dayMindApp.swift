
import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications
import FirebaseMessaging
import KakaoSDKCommon
import KakaoSDKAuth
import UIKit
import FirebaseFunctions
import FamilyControls

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    lazy var loginViewModel = LoginViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // 알림 권한 요청
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
             UNUserNotificationCenter.current().requestAuthorization(
                 options: authOptions,
                 completionHandler: { (granted, error) in
                     if granted {
                         DispatchQueue.main.async {
                             application.registerForRemoteNotifications()
                         }
                     }
                 }
             )
        
        KakaoSDK.initSDK(appKey: "c7a9c099dc5f4cb1ee215efffb2a2bfb")
        
        // FCM 토큰을 생성하고 저장, 앱을 처음 실행할때 마다 호출되므로 매번 최신 토큰을 반영해줌
               Messaging.messaging().token { token, error in
                   if let error = error {
                       print("Error fetching FCM registration token: \(error)")
                   } else if let token = token {
                       print("FCM registration token: \(token)")
                       
                       // 현재 로그인한 사용자의 정보를 불러와 Firestore에 저장
                       UserManager.shared.loadUser { (loadedUser) in
                           if let user = loadedUser {
                               UserManager.shared.saveUserWithFCMToken(user: user, fcmToken: token)
                           } else {
                               print("Failed to load the current user.")
                           }
                       }
                       
                   }
               }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          Messaging.messaging().apnsToken = deviceToken
         
      }
    
    // FCM 토큰 갱신 시 호출되는 메서드, 약간 리스너 같은 역할임 변경되면 반영해줌
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        
        // 현재 로그인한 사용자의 정보를 불러옵니다.
        UserManager.shared.loadUser { (loadedUser) in
            if let user = loadedUser {
                // 가져온 사용자 정보와 새로운 FCM 토큰으로 Firestore를 업데이트합니다.
                UserManager.shared.saveUserWithFCMToken(user: user, fcmToken: fcmToken ?? "")
            } else {
                print("Failed to load the current user.")
            }
        }
    }

    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
   
}
    



@main
struct dayMindApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var userInfoViewModel = UserInfoViewModel()
    @StateObject var missionViewModel = MissionViewModel()
    let center = AuthorizationCenter.shared
    
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    LoadingView2()
                } else {
                    if loginViewModel.isLoggedin {
                        TapBarView()
                            .environmentObject(loginViewModel)
                            .environmentObject(userInfoViewModel)
                            .environmentObject(missionViewModel)
                            .onAppear {
                                Task {
                                    do {
                                        try await center.requestAuthorization(for: .individual)
                                    } catch {
                                        print("Failed to request authorization with error: \(error)")
                                    }
                                }
                            }
                    } else {
                        LoginView().environmentObject(loginViewModel)
                    }
                }
            }
            .onAppear {
                // 로딩 작업을 비동기로 수행합니다.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // 로딩 작업이 완료되면 isLoading을 false로 설정합니다.
                    self.isLoading = false
                }
            }
        }
    }
}

