
import Foundation
import FirebaseFirestore

struct Transaction: Codable {
    var id: String
    var userId: String
    var type: TransactionType
    var amount: Int
    var date: Date


init(userId: String, type: TransactionType, amount: Int, date: Date) {
        self.id = UUID().uuidString // UUID를 생성하고 문자열로 변환하여 id에 할당합니다.
        self.userId = userId
        self.type = type
        self.amount = amount
        self.date = date
    }
}

enum TransactionType: String, Codable {
    case deposit
    case withdrawal
}


func saveTransaction(transaction: Transaction) {
    // Firestore 데이터베이스의 참조 가져오기
    let db = Firestore.firestore()

    // transaction 컬렉션에 대한 참조 가져오기
    let transactionsRef = db.collection("transactions")

    // Transaction을 [String: Any] 딕셔너리로 변환
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(transaction)
        guard var transactionDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            print("Failed to convert transaction to dictionary")
            return
        }

        // 날짜를 밀리초로 변환
        let dateInMilliseconds = transaction.date.timeIntervalSince1970 * 1000
        transactionDict["date"] = dateInMilliseconds // 밀리초로 변환된 값으로 업데이트

        // Firestore에 저장
        transactionsRef.document(transaction.id).setData(transactionDict) { error in
            if let error = error {
                print("Error saving transaction to Firestore: \(error)")
            } else {
                print("Transaction successfully saved!")
            }
        }
    } catch let error {
        print("Error encoding transaction: \(error)")
    }
}



