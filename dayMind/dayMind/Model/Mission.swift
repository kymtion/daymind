
import Foundation
import SwiftUI

struct Mission: Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
    var color: Color
    var step1a: String
    var step1b: String
    var step1c: String
    var step2a: String
    var step2b: String
    var step2c: String
    var step3a: String
    var step3b: String
    var step3c: String
    var confirmmethod1: String
    var confirmmethod2: String
    var examplePhoto1: String
    var examplePhoto2: String
    var examplePhoto3: String
    var description: String
    var timeSetting1: String
    var timeSetting2: String
}
    
    
let missionData: [Mission] = [
    Mission(
        name: "수면",
        imageName: "moon.zzz",
        color: Color(red: 242 / 255, green: 206 / 255, blue: 102 / 255),
        step1a: "STEP 1",
        step1b: "취침시간과 기상시간을 설정하세요",
        step1c: "수면 설정은 하루 1회만 가능합니다. 1회 미션이 끝나면 새로 설정해야 합니다.",
        step2a: "STEP 2",
        step2b: "예치할 금액을 설정하세요",
        step2c: "정해진 시간에 인증하면 환급! 인증하지 못하면 벌금! 돈을 걸어 원하는 수면시간을 통제하세요!",
        step3a: "",
        step3b: "",
        step3c: "",
        confirmmethod1: "취침 30분 전부터 인증 시간입니다. 시작 버튼을 누르면 앱 잠금이 시작되고 인증이 완료됩니다.",
        confirmmethod2: "기상 30분 전부터 인증 시간입니다. 약속한 시간이 지나면 인증 버튼이 비활성화됩니다.",
        examplePhoto1: "인증 예시",
        examplePhoto2: "sample.png",
        examplePhoto3: "야외에서 신고 있는 신발 사진 찍기",
        description: "매일 30분씩 시간을 앞당겨 자는 시간과 일어나는 시간을 조정해보세요. 천천히 변화를 주는 것이 새로운 습관을 이루는 데 더 효과적입니다.",
        timeSetting1: "취침 시간",
        timeSetting2: "기상 시간"
     
    ),
    Mission(
        name: "집중",
        imageName: "iphone.gen2.slash",
        color: Color(red: 242 / 255, green: 206 / 255, blue: 102 / 255),
        step1a: "STEP 1",
        step1b: "앱 허용 리스트를 설정하세요",
        step1c: "이미 설정한 리스트가 있다면 해당 목록 선택! ex) 공부용, 업무용, 수면용",
        step2a: "STEP 2",
        step2b: "시작 시간, 종료 시간을 설정하세요!",
        step2c: "'지금 시작'을 체크할 경우 인증 없이 바로 앱 잠금이 시작됩니다.",
        step3a: "STEP 3",
        step3b: "예치할 금액을 설정하세요",
        step3c: "정해진 시간에 시작하고 설정한 시간까지 포기하지 않으면 환급! 정해진 시간에 시작하지 못하거나 중간에 포기할 경우 벌금! 돈을 걸어 자제력을 높이고, 집중력을 높이세요!",
        confirmmethod1: "시작 시간 30분 전부터 인증 시간입니다. 약속 시간 안에 시작 버튼을 누르면 인증 완료! ",
        confirmmethod2: "종료 시간까지 포기하지 않고 앱 잠금을 유지할 경우 미션 성공!",
        examplePhoto1: "",
        examplePhoto2: "",
        examplePhoto3: "",
        description: "앱 허용 리스트를 통해 전화, 문자, 카카오톡, 지도, 날씨 앱 등 집중에 방해되지 않는 필요한 앱만 허용하여 자제력은 높이고 휴대폰의 필요한 기능은 사용하세요.",
        timeSetting1: "시작 시간",
        timeSetting2: "종료 시간"
        )
]

