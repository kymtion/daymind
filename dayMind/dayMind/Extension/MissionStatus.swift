
import Foundation
import SwiftUI

extension Color {
    static var missionStatus: [String: Color] = [
        "대기중": .gray,
        "진행중": .blue,
        "성공": .green,
        "실패": .red,
        "인증완료1": .purple, // 수정된 부분
        "인증완료2": .purple // 추가된 부분
    ]
}

enum MissionStatus: String, Codable {
    case beforeStart = "대기중"
    case inProgress = "진행중"
    case success = "성공"
    case failure = "실패"
    case verificationCompleted1 = "인증완료1" // 수정된 부분
    case verificationCompleted2 = "인증완료2" // 추가된 부분
    
    var color: Color {
        return Color.missionStatus[self.rawValue] ?? .black
    }
}
