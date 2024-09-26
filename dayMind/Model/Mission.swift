
import Foundation
import SwiftUI

struct Mission: Identifiable {
    var id = UUID()
    var missionType: String
    var imageName: String
    var step1a: String
    var step1b: String
    var step2a: String
    var step2b: String
    var verificationGuide1: String
    var verificationGuide2: String
    var examplePhoto: String
    var refundGuide1: String
    var refundGuide2: String
    var warnings1: String
    var warnings2: String
    var timeSetting1: String
    var timeSetting2: String
}

let missionData: [Mission] = [
    Mission(
        missionType: "수면",
        imageName: "alarm",
        step1a: "오늘 몇 시에 취침하시나요?",
        step1b: "취침 시간을 설정하면, 그 시간 이후로 선택된 필수 앱을 제외한 모든 앱이 차단됩니다.\n\n자기 전에 휴대폰을 놓으세요, 그리고 나의 소중한 수면 시간을 지켜주세요!",
        step2a: "내일 몇 시에 기상하시나요?",
        step2b: "기상 시간을 설정하면 그 시간까지 허용 리스트에 없는 앱들은 접근이 제한됩니다.\n\n야외에서 신발을 신고 사진을 찍는 기상 미션은, 잠에서 깨어나는 가장 확실한 방법이에요",
        verificationGuide1: "약속한 기상 시간 1시간 전부터 사진 인증이 가능해요. 시간 안에 인증을 못하면 자동 실패 처리되니 주의해 주세요!",
        verificationGuide2: "기상 시간이 지나면 앱 차단을 해제할 수 있어요. 차단된 앱을 클릭하고 <미션 완료> 버튼을 누르면, 미션 인증 완료!",
        examplePhoto: "examplePhoto1",
        refundGuide1: "1️⃣ 미션의 모든 인증을 완료하면 관리자가 인증 사진을 검토해요. 인증 사진이 조건에 맞지 않으면 자동으로 미션 실패로 처리되어, 예치금 환급을 받을 수 없어요",
        refundGuide2: "2️⃣ 인증 사진에 문제가 없다면, 그날 밤 자정에 <환급> 버튼이 생성됩니다. 버튼을 누르면 미션 예치금을 즉시 환급받게 돼요",
        warnings1: "1️⃣ 미션 도중 아이폰의 dayMind 앱 스크린 타임 접근 권한을 해제하면 인증이 불가능해집니다.이때 미션 예치금 환급을 받을 수 없으니 주의해 주세요",
        warnings2: "2️⃣ 미션을 '인증' 또는 '포기'하지 않고 다음 미션이 진행되면, 앱 차단이 중복되는 오류가 발생합니다.다음 미션 인증이 불가능해지므로 기존 미션을 완전히 끝내고 다음 미션을 진행해 주세요",
        timeSetting1: "취침 시간",
        timeSetting2: "기상 시간"
    ),
    
    Mission(
        missionType: "집중",
        imageName: "lock.iphone",
        step1a: "어떤 앱이 집중에 방해되나요?",
        step1b: "휴대폰 없이 살 수 없는 요즘, 앱 허용 리스트를 통해 꼭 필요한 앱만 사용하고 집중을 방해하는 앱은 모두 차단하세요! \n\n시작 시간부터 종료 시간까지 온전히 일에만 집중할 수 있어요",
        step2a: "",
        step2b: "",
        verificationGuide1: "시작 시간이 되면 자동으로 선택된 필수 앱을 제외한 모든 앱이 차단됩니다",
        verificationGuide2: "종료 시간이 지나면 앱 차단을 해제할 수 있어요. 차단된 앱을 클릭하고 <미션 완료> 버튼을 누르면, 미션 인증이 완료되며 모든 앱 차단이 해제됩니다!",
        examplePhoto: "examplePhoto2",
        refundGuide1: "차단된 앱을 클릭하고 <미션 완료> 버튼을 누르면 <환급> 버튼이 생성되고 버튼을 누르면 미션 예치금이 결제 취소로 환급됩니다",
        refundGuide2: "",
        warnings1: "1️⃣ 미션 도중 아이폰의 dayMind 앱 스크린 타임 접근 권한을 해제하면 인증이 불가능해집니다.이때 미션 예치금 환급을 받을 수 없으니 주의해 주세요",
        warnings2: "2️⃣ 미션을 '인증' 또는 '포기'하지 않고 다음 미션이 진행되면, 앱 차단이 중복되는 오류가 발생합니다. 다음 미션이 시작되기 전에 기존 미션 인증을 완료하지 않으면 다음 미션의 예치금 환급이 불가능합니다",
        timeSetting1: "시작 시간",
        timeSetting2: "종료 시간"
        )
]

