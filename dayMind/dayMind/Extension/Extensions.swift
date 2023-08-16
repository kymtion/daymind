
import Foundation
import SwiftUI


extension Dictionary {
    func mapKeys<T>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var dictionary: [T: Value] = [:]
        for (key, value) in self {
            dictionary[try transform(key)] = value
        }
        return dictionary
    }
}


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


struct BlueButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(10)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: UIScreen.main.bounds.width * 0.4)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

struct GreenButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(10)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: UIScreen.main.bounds.width * 0.4)
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

extension Int {
    func formattedWithComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
