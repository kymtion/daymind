//
//  MissionStatus.swift
//  dayMind
//
//  Created by 강영민 on 2023/08/03.
//

import Foundation
import SwiftUI

extension Color {
    static var missionStatus: [String: Color] = [
        "대기중": .gray,
        "진행중": .blue,
        "성공": .green,
        "실패": .red,
        "인증완료": .purple
    ]
}

enum MissionStatus: String, Codable {
    case beforeStart = "대기중"
    case inProgress = "진행중"
    case success = "성공"
    case failure = "실패"
    case verificationCompleted = "인증완료"
    
    var color: Color {
        return Color.missionStatus[self.rawValue] ?? .black
    }
}
