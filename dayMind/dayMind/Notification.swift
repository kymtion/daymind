
import Foundation
import FirebaseFirestore
import UserNotifications

let center = UNUserNotificationCenter.current()
center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    // 권한을 처리합니다.
    
    
    let db = Firestore.firestore()
    db.collection("missions").document("yourMissionId").getDocument { (document, error) in
        if let document = document, document.exists {
            let missionData = document.data()
            let selectedTime1 = missionData?["selectedTime1"] as? Date ?? Date()
            
            // 알림을 스케줄링합니다.
            scheduleNotification(at: selectedTime1)
        } else {
            print("Document does not exist")
        }
    }
    
    func scheduleNotification(at date: Date) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "미션 알림"
        content.body = "미션이 시작되었습니다. 확인해주세요."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "MissionStartNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }

