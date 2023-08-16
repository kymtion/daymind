

import SwiftUI

struct TransactionHistoryView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    
    var groupedTransactions: [(key: String, value: [Transaction])] {
        let groupedByDate = Dictionary(grouping: userInfoViewModel.transactions) { transaction in
            formatHistoryDate(transaction.date, format: "MM.dd")
        }
        
        return groupedByDate.sorted(by: { $0.key > $1.key })
    }
    
    var body: some View {
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
