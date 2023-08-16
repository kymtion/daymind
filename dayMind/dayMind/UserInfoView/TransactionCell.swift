
import SwiftUI

struct TransactionCell: View {
    
    var transaction: Transaction
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(transaction.type == .deposit ? "충전" : "출금(카드취소)")
                    .font(.system(size: 19, weight: .semibold))
                
                Spacer()
                Text((transaction.type == .deposit ? "+ " : "- ") + transaction.amount.formattedWithComma() + "원")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(transaction.type == .deposit ? .blue : .red)
            }
            VStack(spacing: 5) {
                HStack {
                    Text("결제 날짜 :")
                    Text(formatTransactionDate(transaction.date, format: "yyyy.MM.dd"))
                    Spacer()
                }
                .font(.system(size: 15))
                .opacity(0.8)
                HStack {
                    Text("결제 시간 :")
                    Text(formatWeekdayAndTime(transaction.date))
                    
                    Spacer()
                }
                .font(.system(size: 15))
                .opacity(0.8)
            }
        }
        .padding(.horizontal, 15)
    }
}

func formatTransactionDate(_ date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = format
    return formatter.string(from: date)
}

func formatWeekdayAndTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "a hh:mm"
    return "\(formatter.string(from: date))"
}


struct TransactionCell_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCell(transaction: Transaction(userId: "user123", type: .withdrawal, amount: 3000, date: Date()))
    }
}
