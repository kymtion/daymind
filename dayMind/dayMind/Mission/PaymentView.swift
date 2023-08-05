import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var missionViewModel: MissionViewModel
    @State private var amount: String = ""
    @State private var actualAmount: Int = 0 // 데이터를 전송할때 사용될 실제 값(콤마 없음)
    
    var body: some View {
        
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                
                VStack {
                    Text("예치금")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack {
                        Spacer()
                            TextField("금액을 입력하세요", text: $amount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                        Spacer()
                        Text("원")
                            .font(.system(size: 20, weight: .semibold))
                        
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.7)
                    
                    
                    
                    Rectangle()
                        .fill(Color.green)  // 색상 변경
                        .frame(height: 2) // 두께 변경
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                    
                   
                    
                    
                }
            }
            .onTapGesture {
                formatAndRoundAmount()
                hideKeyboard()
            }
        }
    }
    
    func formatAndRoundAmount() {
            let numbersOnly = amount.filter { "0"..."9" ~= $0 }
            if var intValue = Int(numbersOnly) {
                // 입력된 값이 1,000원 미만이면 1,000원으로, 200,000원 초과이면 200,000원으로 설정
                if intValue < 1000 {
                    intValue = 1000
                } else if intValue > 200000 {
                    intValue = 200000
                }

                // 입력된 값이 1,000원 단위가 아닌 경우, 1,000원 단위로 반올림
                actualAmount = (intValue / 1000) * 1000 // 실제 계산에 사용될 값

                // 금액을 포맷팅하여 저장
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                if let formattedNumber = numberFormatter.string(from: NSNumber(value: actualAmount)) {
                    amount = formattedNumber
                }
            }
        }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


//    self.missionViewModel.selectedTime1 = self.selectedTime1
//    self.missionViewModel.selectedTime2 = self.selectedTime2
//    self.createdMission = self.missionViewModel.createMission(missionType: mission.missionType)
//    if let createdMission = self.createdMission {
//        self.missionViewModel.missionMonitoring(selectedTime1: self.selectedTime1, selectedTime2: self.selectedTime2, missionId: createdMission.id)



struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView()
    }
}
