
import SwiftUI
import Firebase
import FirebaseAuth
import KakaoSDKCommon
import KakaoSDKAuth
import UIKit
import FirebaseFunctions

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    lazy var loginViewModel = LoginViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        KakaoSDK.initSDK(appKey: "c7a9c099dc5f4cb1ee215efffb2a2bfb")
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
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
    
    
    var body: some Scene {
        WindowGroup {
            if loginViewModel.isLoggedin {
                TapBarView()
                    .environmentObject(loginViewModel)
                    .environmentObject(userInfoViewModel)
            } else {
                LoginView().environmentObject(loginViewModel)
            }
        }
    }
}




// --------------------------------------------푸시 알람 관련 코드 시작 ---------------------------------------------------
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        if let token = fcmToken {
//            print("Firebase registration token: \(token)")
//        } else {
//            print("Firebase registration token is nil")
//        }
//    }
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//        fetchFCMToken()
//    }
//
//    func fetchFCMToken() {
//           Messaging.messaging().token { token, error in
//               if let error = error {
//                   print("Error fetching FCM registration token: \(error)")
//               } else if let token = token {
//                   print("FCM registration token: \(token)")
//                   // 여기서 필요한 작업 수행
//               }
//           }
//       }
//    // --------------------------------------------푸시 알람 관련 코드 끝 ---------------------------------------------------
