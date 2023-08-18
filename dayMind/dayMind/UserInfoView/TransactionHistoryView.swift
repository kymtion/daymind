

import SwiftUI

struct TransactionHistoryView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    
    // 총 충전 금액 계산
        var depositAmount: Int {
            return userInfoViewModel.transactions.filter { $0.type == .deposit }.reduce(0) { $0 + $1.amount }
        }
        
        // 총 출금 금액 계산
        var withdrawalAmount: Int {
            return userInfoViewModel.transactions.filter { $0.type == .withdrawal }.reduce(0) { $0 + $1.amount }
        }
    
    
    // 리스트 목록을 날짜별로 그룹해주고 시간 순서대로 나열해주는 코드
    var groupedTransactions: [(key: String, value: [Transaction])] {
        let groupedByDate = Dictionary(grouping: userInfoViewModel.transactions) { transaction in
            formatHistoryDate(transaction.date, format: "MM.dd")
        }
        return groupedByDate.map { key, value in
                    (key, value.sorted(by: { $0.date > $1.date }))
                }.sorted(by: { $0.key > $1.key })
            }
    
    
    var body: some View {
        
        
        VStack(spacing: 10) {
            HStack {
                Text("총 충전 금액")
                    .font(.system(size: 17, weight: .medium))
                    .opacity(0.7)
                Spacer()
                Text("\(depositAmount.formattedWithComma())원")
                    .font(.system(size: 17, weight: .medium))
            }
            Divider()
            HStack {
                Text("총 출금 금액")
                    .font(.system(size: 17, weight: .medium))
                    .opacity(0.7)
                Spacer()
                Text("\(withdrawalAmount.formattedWithComma())원")
                    .font(.system(size: 17, weight: .medium))
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        
        List {
            ForEach(groupedTransactions, id: \.key) { key, transactions in
                Section(header: Text(key).font(.system(size: 15, weight: .semibold))) {
                    ForEach(transactions) { transaction in
                        TransactionCell(transaction: transaction)
                    }
                }
            }
        }
    }
}

func formatHistoryDate(_ date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}

struct TransactionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionHistoryView()
            .environmentObject(UserInfoViewModel())
    }
}
