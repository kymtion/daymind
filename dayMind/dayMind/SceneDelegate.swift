
import Foundation
import KakaoSDKAuth
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 앱그룹에 저장된 미션들을 Firestore에 저장합니다.
        let appGroupMissions = AppGroupMission.loadMissionAppGroup()
        for appGroupMission in appGroupMissions {
            let firestoreMission = MissionTransformer.transformToFirestore(appGroupMission: appGroupMission)
            FirestoreMission.saveFirestoreMission(mission: firestoreMission)
        }
        
        FirestoreMission.loadUserMissions { loadedMissions in
        }
            print("앱이 포그라운드로 전환되었습니다!") // 원하는 문구 출력
        }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
   
}
