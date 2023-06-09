//
//  MissionDetile.swift
//  dayMind
//
//  Created by 강영민 on 2023/05/11.
//

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
    var step4a: String
    var step4b: String
    var step4c: String
    var confirmmethod1: String
    var confirmmethod2: String
    var examplePhoto1: String
//    var examplePhoto2: Image
    var description: String
}
    
    
let missionData: [Mission] = [
    Mission(
        name: "수면",
        imageName: "moon.zzz",
        color: Color.yellow,
        step1a: "STEP 1",
        step1b: "취침시간과 기상시간을 설정하세요",
        step1c: "수면설정은 하루 1회성 입니다. 1회 미션이 끝나면 새로 설정해야 합니다.",
        step2a: "STEP 2",
        step2b: "예치할 금액을 설정하세요",
        step2c: "정해진 시간에 인증하면 환급! 인증하지 못하면 벌금! 돈을 걸어 원하는 수면시간을 통제하세요!",
        step3a: "",
        step3b: "",
        step3c: "",
        step4a: "",
        step4b: "",
        step4c: "",
        confirmmethod1: "취침 30분 전부터 인증 시간입니다. 시작버튼을 누르면 앱 잠금이 시작되고 인증이 완료됩니다.",
        confirmmethod2: "기상 30분 전부터 인증 시간입니다. 야외에 나가 신발 사진을 촬영하면 인증이 완료됩니다.",
        examplePhoto1: "인증 예시",
//        examplePhoto2: ,
        description: "수면 미션에 대한 설명"
     
    ),
    Mission(
        name: "집중",
        imageName: "iphone.gen2.slash",
        color: Color.blue,
        step1a: "STEP 1",
        step1b: "앱 허용 리스트를 설정하세요",
        step1c: "이미 설정한 리스트가 있다면 해당 목록 선택! ex) 공부할 때, 일 할때, 운동할 때",
        step2a: "STEP 2",
        step2b: "시작 시간, 종료 시간을 설정하세요!",
        step2c: "'지금 시작'을 체크할 경우 인증 없이 바로 앱 잠금이 시작됩니다.",
        step3a: "STEP 3",
        step3b: "쉬는 시간을 설정하세요",
        step3c: "집중 모드 중 급한 용무가 생기거나, 쉬어야 하는 상황에 여러번 앱 잠금을 해제할 수 있습니다. 단, 설정한 시간 모두 소진 시 쉬는 시간 사용이 불가합니다.",
        step4a: "STEP 4",
        step4b: "예치할 금액을 설정하세요",
        step4c: "정해진 시간에 시작하고 설정한 시간까지 포기하지 않으면 환급! 정해진 시간에 시작하지 못하거나 중간에 포기할 경우 벌금! 돈을 걸어 자제력을 높이고, 집중력을 높이세요!",
        confirmmethod1: "시작 시간 30분 전부터 인증 가능 시간입니다. 시작 시간이 되기 전까지 시작버튼을 눌러 앱잠금을 시작해야 인증이 완료됩니다.",
        confirmmethod2: "종료 시간까지 포기하지 않고 앱 잠금을 유지할 경우 미션 성공!",
        examplePhoto1: "",
//        examplePhoto2: ,
        description: "앱 허용 리스트를 통해 전화, 문자, 카카오톡, 지도, 날씨 앱 등 집중에 방해되지 않는 필요한 앱만 허용하여 자제력은 높이고 휴대폰의 필요한 기능은 사용하세요."
        )
]

