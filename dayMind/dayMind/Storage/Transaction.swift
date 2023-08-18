
import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Transaction: Codable, Identifiable {
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

func loadTransactions(completion: @escaping ([Transaction]?) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        print("No current user logged in.")
        completion(nil)
        return
    }

    // Firestore 데이터베이스의 참조 가져오기
    let db = Firestore.firestore()

    // 현재 사용자의 UID와 일치하는 트랜잭션만 가져오기
    db.collection("transactions").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
        guard let documents = snapshot?.documents else {
            print("Error fetching transactions: \(error?.localizedDescription ?? "")")
            completion(nil)
            return
        }
        
        var transactions: [Transaction] = []
        
        // 각 문서를 Transaction 객체로 디코딩
        for document in documents {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: document.data(), options: []),
                  var transaction = try? JSONDecoder().decode(Transaction.self, from: jsonData) else {
                print("Error decoding transaction")
                continue
            }
            
            // 밀리초에서 Date로 변환
            if let dateInMilliseconds = document.data()["date"] as? Double {
                transaction.date = Date(timeIntervalSince1970: dateInMilliseconds / 1000)
            }
            
            transactions.append(transaction)
        }
        
        completion(transactions)
    }
}


func listenForTransactions(completion: @escaping ([Transaction]) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        print("No current user logged in.")
        return
    }

    let db = Firestore.firestore()

    db.collection("transactions")
        .whereField("userId", isEqualTo: userId)
        .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            let transactions = documents.compactMap { document -> Transaction? in
                let transactionDict = document.data()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: transactionDict, options: []),
                      var transaction = try? JSONDecoder().decode(Transaction.self, from: jsonData) else {
                    return nil
                }

                // 밀리초에서 Date로 변환
                if let dateInMilliseconds = transactionDict["date"] as? Double {
                    transaction.date = Date(timeIntervalSince1970: dateInMilliseconds / 1000)
                }

                return transaction
            }
            
            completion(transactions)
        }
}
