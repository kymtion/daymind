import Foundation
import FirebaseStorage
import FamilyControls
import ManagedSettings
import DeviceActivity
import UIKit
import FirebaseAuth
import UserNotifications

class MissionViewModel: ObservableObject {
    @Published var currentStore: String = ""
    @Published var imageURL: URL?
    @Published var selectedTime1: Date = Date()
    @Published var selectedTime2: Date = Date()
    @Published var managedSettings: [ManagedSettingsStore.Name: FamilyActivitySelection] = [:]
    @Published var missions: [FirestoreMission] = []
    @Published var actualAmount: Int = 0
    @Published var showDetailView: Bool = false
    @Published var showTimeSettingView: Bool = false
    @Published var showPaymentView: Bool = false
    @Published var selectedMission: Mission?
    
    @Published var startNotificationEnabled: Bool = true {
            didSet {
                updateNotificationSettings()
            }
        }
        
        @Published var endNotificationEnabled: Bool = true {
            didSet {
                updateNotificationSettings()
            }
        }
        
        @Published var before10MinNotificationEnabled: Bool = true {
            didSet {
                updateNotificationSettings()
            }
        }

        @Published var firebasePushNotificationEnabled: Bool = true {
            didSet {
                updateNotificationSettings()
            }
        }

    
    private let storage = Storage.storage()
    private let userDefaultsKey = "managedSettings"
    private let deviceActivityCenter = DeviceActivityCenter()
    
    
    
    init() {
        self.managedSettings = ManagedSettings.loadManagedSettings()
        
        FirestoreMission.loadUserMissions { missions in
            DispatchQueue.main.async {
                self.missions = missions
            }
        }
        // 파이어스토어에서 사용자의 알림 설정을 불러오는 로직
        UserManager.shared.loadUser { (user) in
            guard let user = user, let notificationSettings = user.notificationSettings else {
                print("Failed to load user or user's notification settings.")
                return
            }
            
            DispatchQueue.main.async {
                self.startNotificationEnabled = notificationSettings["startNotificationEnabled"] ?? true
                self.endNotificationEnabled = notificationSettings["endNotificationEnabled"] ?? true
                self.before10MinNotificationEnabled = notificationSettings["before10MinNotificationEnabled"] ?? true
                self.firebasePushNotificationEnabled = notificationSettings["firebasePushNotificationEnabled"] ?? true
            }
        }
    }
    
    
    private func updateNotificationSettings() {
        UserManager.shared.updateNotificationSettingsInFirestore(
            startNotificationEnabled: startNotificationEnabled,
            endNotificationEnabled: endNotificationEnabled,
            before10MinNotificationEnabled: before10MinNotificationEnabled,
            firebasePushNotificationEnabled: firebasePushNotificationEnabled
        )
    }
  
    
    // 충전 금액 데이터 저장
    func saveDepositTransaction(rechargeAmount: Int) {
        if let userId = Auth.auth().currentUser?.uid {
            let transaction = Transaction(userId: userId, type: .deposit, amount: rechargeAmount, date: Date())
            saveTransaction(transaction: transaction)
        }
    }
    
    
    // 미션 등록되면 모든 모달이 닫혀서 초기 뷰로 돌아오게함
    func closeAllModals() {
        showDetailView = false
        showTimeSettingView = false
        showPaymentView = false
    }
    
    // 파이어베이스 인증사진(메타데이터) 업로드
    func uploadImage(_ image: UIImage?, for mission: FirestoreMission, captureTime: Date) {
        let storageRef = storage.reference().child("수면미션/\(mission.id.uuidString).jpg")
        
        if let uploadData = image?.jpegData(compressionQuality: 0.5) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error)")
                } else {
                    print("Upload successful!")
                    
                    // 메타데이터 생성
                    let dateFormatter = ISO8601DateFormatter()
                    let selectedTime1Str = dateFormatter.string(from: self.selectedTime1)
                    let selectedTime2Str = dateFormatter.string(from: self.selectedTime2)
                    let captureTimeStr = dateFormatter.string(from: captureTime)
                    
                    let missionData: [String: String] = [
                        "selectedTime1": selectedTime1Str,
                        "selectedTime2": selectedTime2Str,
                        "missionType": mission.missionType,
                        "id": mission.id.uuidString,
                        "captureTime": captureTimeStr,
                        "missionStatus": mission.missionStatus.rawValue
                        // 다른 필요한 메타데이터를 추가
                    ]
                    
                    // 메타데이터 업데이트
                    let newMetadata = StorageMetadata()
                    newMetadata.customMetadata = missionData
                    
                    storageRef.updateMetadata(newMetadata) { (updatedMetadata, error) in
                        if let error = error {
                            print("Error updating metadata: \(error)")
                        } else {
                            print("Metadata update successful!")
                        }
                    }
                }
            }
        }
    }
    
    // 미션 상태 (진행중 -> 인증완료1)
    func toVerification1(missionId: UUID) {
        if let mission = missions.first(where: { $0.id == missionId }),
           mission.missionStatus == .inProgress {
            FirestoreMission.updateMissionStatus(missionId: mission.id, newStatus: .verificationCompleted1)
        }
        cancelAllNotifications(for: missionId)
    }
    
    
    
    
    // 미션 상태 (대기중 -> 진행중)
    func updateMissionStatuses() {
        print("Updating mission statuses...")
        let calendar = Calendar.current
        
        // 현재 날짜에서 초를 제거 (분 단위까지만)
        let currentDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        guard let currentDate = calendar.date(from: currentDateComponents) else { return }
        
        for mission in missions {
            if mission.missionStatus == .beforeStart {
                // 미션 날짜에서 초를 제거 (분 단위까지만)
                let missionDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: mission.selectedTime1)
                guard let missionDate = calendar.date(from: missionDateComponents) else { continue }
                
                // 분 단위까지만 비교
                if currentDate >= missionDate {
                    FirestoreMission.updateMissionStatus(missionId: mission.id, newStatus: .inProgress)
                }
            }
        }
        
        FirestoreMission.loadUserMissions { fetchedMissions in
            self.missions = fetchedMissions
        }
    }
    
    // 미션 상태 -> 실패
    func giveUpMission(missionId: UUID) {
        FirestoreMission.updateMissionStatus(missionId: missionId, newStatus: .failure)
        FirestoreMission.loadUserMissions { fetchedMissions in
            self.missions = fetchedMissions
        }
        
        // 알림 취소
        cancelAllNotifications(for: missionId)
    }
    
    // 미션상태 (인증완료2 -> 성공)
    func completeMission(missionId: UUID) {
        if let mission = missions.first(where: { $0.id == missionId }),
           mission.missionStatus == .verificationCompleted2 {
            FirestoreMission.updateMissionStatus(missionId: mission.id, newStatus: .success)
            FirestoreMission.loadUserMissions { fetchedMissions in
                self.missions = fetchedMissions
            }
        }
    }
    
    // 모든 알림 취소 함수
    func cancelAllNotifications(for missionId: UUID) {
        let center = UNUserNotificationCenter.current()
        
        let identifiers = [
            "MissionNotification_\(missionId)_Start",
            "MissionNotification_\(missionId)_End",
            "MissionNotification_\(missionId)_Before10Min"
        ]
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // 알림 스케줄링 함수
    func scheduleNotification(for missionId: UUID, at date: Date, type: String, title: String, with message: String) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title  // 여기서 타이틀 설정
        content.body = message
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "MissionNotification_\(missionId)_\(type)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    // 미션 데이터 등록(생성)
    func createMission() -> FirestoreMission? {
        guard let selectedMission = selectedMission else { return nil }
        let newMission = FirestoreMission(id: UUID(),
                                          selectedTime1: self.selectedTime1,
                                          selectedTime2: self.selectedTime2,
                                          currentStore: self.currentStore,
                                          missionType: selectedMission.missionType,
                                          imageName: selectedMission.imageName,
                                          missionStatus: MissionStatus.beforeStart,
                                          actualAmount: self.actualAmount,
                                          userId: Auth.auth().currentUser?.uid ?? "")
        self.missions.append(newMission)
        FirestoreMission.saveFirestoreMission(mission: newMission)
        AppGroupMission.saveMissionAppGroup(missions: self.missions.map { MissionTransformer.transform(firestoreMission: $0) })
        
        // 시작 시간 알림
        if startNotificationEnabled {
            scheduleNotification(for: newMission.id, at: newMission.selectedTime1, type: "Start", title: "미션이 시작되었습니다 😄", with: "남은 시간까지 화이팅!")
        }
        
        // 미션 타입이 '집중'이면, 종료 시간 알림
        if newMission.missionType == "집중" && endNotificationEnabled {
            scheduleNotification(for: newMission.id, at: newMission.selectedTime2, type: "End", title: "미션이 종료되었습니다 😄", with: "차단된 앱을 클릭하여 <미션완료> 버튼을 누르면, 인증이 완료되며 모든 앱 차단이 해제됩니다!")
        }
        
        // 미션 타입이 '수면'이면, 종료 시간 10분 전 알림
        if newMission.missionType == "수면" && before10MinNotificationEnabled {
            if let timeBefore10Min = Calendar.current.date(byAdding: .minute, value: -10, to: newMission.selectedTime2) {
                scheduleNotification(for: newMission.id, at: timeBefore10Min, type: "Before10Min", title: "미션인증을 완료하셨나요? 😱", with: "미션이 10분 후에 종료됩니다. 시간 안에 인증을 못하면 자동 실패 처리됩니다.")
            }
        }
        return newMission
    }
    
    
    
    


    
    
    // 미션 모니터링 시작 함수
    func missionMonitoring(selectedTime1: Date, selectedTime2: Date, missionId: UUID) {
        let time1 = Calendar.current.dateComponents([.hour, .minute], from: selectedTime1)
        let time2 = Calendar.current.dateComponents([.hour, .minute], from: selectedTime2)
        
        let activityName = DeviceActivityName(rawValue: missionId.uuidString)
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: DeviceActivitySchedule(
                intervalStart: DateComponents(hour: time1.hour, minute: time1.minute),
                intervalEnd: DateComponents(hour: time2.hour, minute: time2.minute),
                repeats: false
            ))
        } catch DeviceActivityCenter.MonitoringError.unauthorized {
            print("권한이 해제되었습니다.")
        } catch {
            print("Error starting device activity monitoring: \(error)")
        }
    }
    
    // 모니터링 중단 함수
    func stopMonitoring(missionId: UUID) {
        let activityName = DeviceActivityName(rawValue: missionId.uuidString)
        deviceActivityCenter.stopMonitoring([activityName])
        print("Stopping monitoring for \(missionId.uuidString)")
        
        if let mission = missions.first(where: { $0.id == missionId }) {
            let currentStoreName = ManagedSettingsStore.Name(rawValue: mission.currentStore)
            let selectedList = ManagedSettingsStore(named: currentStoreName)
            selectedList.clearAllSettings()
        }
    }
    
    
    
    
    // 앱 허용 리스트 추가, 삭제, 이름 변경 메소드 모음
    func addStore(_ store: String, selection: FamilyActivitySelection) {
        let storeName = ManagedSettingsStore.Name(rawValue: store)
        self.managedSettings[storeName] = selection
        ManagedSettings.saveManagedSettings(settings: self.managedSettings)
    }
    
    func deleteStore(storeName: String) {
        let storeName = ManagedSettingsStore.Name(rawValue: storeName)
        self.managedSettings.removeValue(forKey: storeName)
        ManagedSettings.saveManagedSettings(settings: self.managedSettings)
    }
    
    func updateStoreName(oldName: String, newName: String) {
        let oldStoreName = ManagedSettingsStore.Name(rawValue: oldName)
        let newStoreName = ManagedSettingsStore.Name(rawValue: newName)
        
        if let oldValue = self.managedSettings[oldStoreName] {
            self.managedSettings.removeValue(forKey: oldStoreName)
            self.managedSettings[newStoreName] = oldValue
            ManagedSettings.saveManagedSettings(settings: self.managedSettings)
        }
    }
}
