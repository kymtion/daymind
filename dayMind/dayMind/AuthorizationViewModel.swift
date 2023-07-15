//
//import Foundation
//import SwiftUI
//import Combine
//import FamilyControls
//
//class AuthorizationViewModel: ObservableObject {
//    static let shared = AuthorizationViewModel(authorizationCenter: AuthorizationCenter.shared)
//    
//    @Published var authorizationStatus: AuthorizationStatus
//    private var cancellable: AnyCancellable? = nil
//
//    init(authorizationCenter: AuthorizationCenter) {
//        self.authorizationStatus = authorizationCenter.authorizationStatus
//        self.cancellable = authorizationCenter.$authorizationStatus
//            .sink() { [weak self] status in
//                self?.authorizationStatus = status
//                switch status {
//                case .notDetermined:
//                    // Handle the change to notDetermined.
//                    print("사용자에게 권한 승인 질문에 대한 응답을 아직 받지 못함")
//                case .denied:
//                    // Handle the change to denied.
//                    print("권한 해제됨")
//                case .approved:
//                    // Handle the change to approved.
//                    print("권한 승인 됨")
//                default:
//                    break
//                }
//            }
//    }
//}
