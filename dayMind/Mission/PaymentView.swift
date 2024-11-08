import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var missionViewModel: MissionViewModel
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var displayAmount: String = ""
    @State private var showAlertForEmptyAmount: Bool = false // 예치금 입력 알림을 표시할지 여부
    @State private var showAlertForConfirmation: Bool = false // 미션 등록 확인 알림을 표시할지 여부
    @State private var alertType: AlertType? // 현재 표시될 알림 유형 저장
    @State private var showCancelPolicyModal: Bool = false // 결제 취소 규정 모달 표시 여부

    
    enum AlertType: Identifiable {
        case emptyAmount
        case confirmMission
        
        var id: AlertType { self } // 고유 식별자로 자기 자신을 사용
    }
    
    var body: some View {
  
            VStack {
                HStack {
                    Button {
                        missionViewModel.showPaymentView.toggle()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                            Text("Back")
                                .font(.system(size: 18, weight: .regular))
                            Spacer()
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                
                ScrollView {
                    
                    VStack(spacing: 20) {
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("예치금")
                                    .font(.system(size: 23, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                
                                Text("미션을 성공하면 환급이 가능합니다.")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .opacity(0.7)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        
                        HStack {
                            Spacer()
                            TextField("금액", text: $displayAmount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 35, weight: .semibold))
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .onChange(of: displayAmount) { newValue in
                                    displayAmount = newValue.filter { $0.isNumber || $0 == ","
                                    }
                                }
                            Spacer()
                            Text("원")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .opacity(0.85)
                            
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.7)
                        
                        VStack{
                            Rectangle()
                                .fill(Color.green.opacity(0.8))  // 색상 변경
                                .frame(height: 2) // 두께 변경
                                .frame(width: UIScreen.main.bounds.width * 0.75)
                            
                            Text("최소 1천원 ~ 최대 20만원 (1천원 단위 가능)")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .opacity(0.7)
                        }
                        
                    }
                    .padding(.vertical, 40)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("충전 및 결제")
                                .font(.system(size: 23, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
//                            Text("현재 보유 금액 \(userInfoViewModel.balance)원")
//                                .font(.system(size: 13, weight: .regular))
//                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
//                                .opacity(0.7)
                            Spacer()
                        }
                        HStack {
                            Text("미션 예치금")
                            Spacer()
                            Text("\(displayAmount) 원")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        
//                        HStack {
//                            Text("사용 금액 ")
//                            Spacer()
//                            Text("\(missionViewModel.actualAmount - calculateRechargeAmount()) 원")
//                        }
//                        .font(.system(size: 17, weight: .medium))
//                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        
                        HStack {
                            Text("충전 금액")
                                .font(.system(size: 23, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Spacer()
                            Text("\(missionViewModel.actualAmount) 원")
                                .font(.system(size: 23, weight: .semibold))
                                .foregroundColor(.red)
                                .opacity(0.8)
                        }
                        
                        
                        
                    }
                    .padding(.horizontal, 30)
                    
                    BlueButton(title: "결제 및 등록") {
                        if displayAmount.isEmpty {
                            alertType = .emptyAmount // 예치금이 입력되지 않았을 때 알림 표시
                        } else {
                            formatAndRoundAmount()
                            alertType = .confirmMission // 미션 등록 확인 알림 표시
                        }
                    }
                    .alert(item: $alertType) { alertType in
                        switch alertType {
                        case .emptyAmount:
                            return Alert(title: Text("알림"), message: Text("금액을 입력해주세요!"), dismissButton: .default(Text("확인")))
                        case .confirmMission:
                            return Alert(title: Text("알림"), message: Text("미션을 등록하시겠습니까?"),
                                         primaryButton: .default(Text("예"), action: {
                                // 금액 계산
                                let rechargeAmount = missionViewModel.actualAmount
                                var finalBalance = userInfoViewModel.balance
//                                
//                                if rechargeAmount > 0 {
//                                    finalBalance += rechargeAmount
//                                    finalBalance -= missionViewModel.actualAmount
//                                } else {
//                                    finalBalance -= missionViewModel.actualAmount
//                                }
                                
                                // 잔액 업데이트
                                userInfoViewModel.updateBalance(newBalance: finalBalance) { error in
                                    if let error = error {
                                        print("Failed to update balance: \(error.localizedDescription)")
                                    } else {
                                        userInfoViewModel.balance = finalBalance
                                        // 미션 생성 및 모니터링 시작
                                        if let createdMission = self.missionViewModel.createMission() {
                                            self.missionViewModel.missionMonitoring(selectedTime1: self.missionViewModel.selectedTime1,
                                                                                    selectedTime2: self.missionViewModel.selectedTime2,
                                                                                    missionId: createdMission.id)
                                            missionViewModel.closeAllModals()
                                            
                                            missionViewModel.saveDepositTransaction(rechargeAmount: rechargeAmount)
                                        }
                                    }
                                }
                            }),
                                         secondaryButton: .cancel(Text("아니오"))
                            )
                        }
                    }
                    
                    Text("결제 조건 및 서비스 약관에 동의합니다")
                        .foregroundColor(.gray)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 16)
                    
                    // 결제 취소 규정 및 이용약관 버튼
                              HStack {
                                  // 결제 취소 규정 버튼
                                  Button(action: {
                                      showCancelPolicyModal.toggle()
                                  }) {
                                      Text("결제 취소 규정")
                                          .font(.system(size: 14, weight: .regular))
                                          .underline()
                                          .foregroundColor(.gray)
                                  }
                                  
                                  // 이용약관 버튼 (링크)
                                  Link(destination: URL(string: "https://daymind.co.kr")!) {
                                      Text("이용약관")
                                          .font(.system(size: 14, weight: .regular))
                                          .underline()
                                          .foregroundColor(.gray)
                                  }
                              }
                              .padding(.top, 1)
                          }
                          .sheet(isPresented: $showCancelPolicyModal) {
                              // 결제 취소 규정 모달 내용
                              VStack {
                                  Text("결제 취소 규정")
                                      .font(.system(size: 20, weight: .bold))
                                  
                                  ScrollView {
                                      Text("""
                                      1. 미션 등록 후 30분 이내에 결제 취소 및 예치금 전액 환불이 가능합니다.
                                      (단, 미션 시작 후에는 시간에 관계없이 취소 불가능)
                                      
                                      2. 미션 등록 후 30분 이후엔 미션 취소가 불가능합니다.
                                      """)
                                      .multilineTextAlignment(.leading)
                                      .font(.system(size: 15, weight: .medium))
                                      .lineSpacing(5)

                                  }
                              }
                              .padding()
                              .presentationDetents([.fraction(0.3)])
                }
                .onTapGesture {
                    formatAndRoundAmount()
                    hideKeyboard()
                }
                .onAppear {
                    userInfoViewModel.loadUserBalance()
                }
            }
        }
    
    
    func formatAndRoundAmount() {
        let numbersOnly = displayAmount.filter { "0"..."9" ~= $0 }
        if var intValue = Int(numbersOnly) {
            // 입력된 값이 1,000원 미만이면 1,000원으로, 200,000원 초과이면 200,000원으로 설정
            if intValue < 1000 {
                intValue = 1000
            } else if intValue > 200000 {
                intValue = 200000
            }
            
            // 입력된 값이 1,000원 단위가 아닌 경우, 1,000원 단위로 반올림
            intValue = (intValue / 1000) * 1000 // 실제 계산에 사용될 값
            
            missionViewModel.actualAmount = intValue
            
            // 금액을 포맷팅하여 저장
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            if let formattedNumber = numberFormatter.string(from: NSNumber(value: intValue)) {
                displayAmount = formattedNumber
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
//    // 예치금과 남은잔고의 크기 비교에 따른 충전금액 산출 로직 -> 현대 카드 심사로 잠시 삭제
//    func calculateRechargeAmount() -> Int {
//        if missionViewModel.actualAmount > userInfoViewModel.balance {
//            return missionViewModel.actualAmount - userInfoViewModel.balance
//        } else {
//            return 0
//        }
//    }
    
    
}






struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView()
            .environmentObject(MissionViewModel()) // 예시 객체, 실제 앱에서 필요한 초기값으로 설정해야 할 수도 있습니다.
            .environmentObject(UserInfoViewModel()) // 예시 객체, 실제 앱에서 필요한 초기값으로 설정해야 할 수도 있습니다.
    }
}
