
import SwiftUI

struct WithdrawalView: View {
    @State private var displayAmount: String = ""
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var alertType: AlertType? // 현재 표시될 알림 유형 저장
    
    enum AlertType: Identifiable {
        case invalidAmount
        case confirmWithdrawal
        
        var id: AlertType { self } // 고유 식별자로 자기 자신을 사용
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                
                VStack(spacing: 20) {
                    
                    Text("현재 보유 잔액")
                        .font(.system(size: 16, weight: .semibold))
                        .opacity(0.7)
                    Text("\(userInfoViewModel.balance.formattedWithComma())원")
                        .font(.system(size: 35, weight: .bold))
                }
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 10)
                    .foregroundColor(.gray.opacity(0.1))
                VStack {
                    HStack {
                        Spacer()
                        TextField("금액", text: $displayAmount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 35, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .onChange(of: displayAmount) { newValue in
                                let numbersOnly = newValue.filter { "0"..."9" ~= $0 }
                                        if var intValue = Int(numbersOnly) {
                                            // NumberFormatter를 사용하여 숫자에 콤마 추가
                                            let numberFormatter = NumberFormatter()
                                            numberFormatter.numberStyle = .decimal
                                            if let formattedNumber = numberFormatter.string(from: NSNumber(value: intValue)) {
                                                displayAmount = formattedNumber
                                            }
                                        }
                                    }
                        Spacer()
                        Text("원")
                            .font(.system(size: 20, weight: .semibold))
                            .opacity(0.85)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.7)
                    
                    
                    VStack {
                        Rectangle()
                            .fill(Color.green.opacity(0.8)) // 색상 변경
                            .frame(height: 2) // 두께 변경
                            .frame(width: UIScreen.main.bounds.width * 0.75)
                        
                        Text("출금 가능 금액: \(userInfoViewModel.balance.formattedWithComma())원")
                            .font(.system(size: 14, weight: .regular))
                            .opacity(0.7)
                    }
                }
                BlueButton(title: "출금하기") {
                    if let withdrawalAmount = Int(displayAmount.filter { "0"..."9" ~= $0 }), withdrawalAmount > 0, withdrawalAmount <= userInfoViewModel.balance {
                        alertType = .confirmWithdrawal // 출금 확인 알림 표시
                    } else {
                        alertType = .invalidAmount // 금액이 유효하지 않거나 잔액보다 큰 경우 알림 표시
                    }
                }
                .alert(item: $alertType) { alertType in
                    switch alertType {
                    case .invalidAmount:
                        return Alert(title: Text("오류"), message: Text("금액이 유효하지 않습니다."), dismissButton: .default(Text("확인")))
                    case .confirmWithdrawal:
                        return Alert(title: Text("알림"), message: Text("금액을 출금하시겠습니까?"),
                                     primaryButton: .default(Text("예"), action: {
                            if let withdrawalAmount = Int(displayAmount.filter { "0"..."9" ~= $0 }) {
                                let newBalance = userInfoViewModel.balance - withdrawalAmount
                                userInfoViewModel.updateBalance(newBalance: newBalance)
                                
                                userInfoViewModel.saveWithdrawalTransaction(withdrawalAmount: withdrawalAmount)
                            }
                        }),
                                     secondaryButton: .cancel(Text("아니오"))
                        )
                    }
                }
            }
        }
        .padding(.vertical, 30)
    }
}
    
    
    struct WithdrawalView_Previews: PreviewProvider {
        static var previews: some View {
            WithdrawalView()
                .environmentObject(UserInfoViewModel())
        }
    }
