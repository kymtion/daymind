import Foundation
import FirebaseStorage
import FamilyControls
import ManagedSettings
import DeviceActivity
import UIKit

class MissionViewModel: ObservableObject {
    @Published var currentStore: String = ""
    @Published var imageURL: URL?
    @Published var selectedTime1: Date = Date()
    @Published var selectedTime2: Date = Date()
    @Published var managedSettings: [ManagedSettingsStore.Name: FamilyActivitySelection] = [:]
    @Published var missions: [FirestoreMission] = []
    
    private let storage = Storage.storage()
    private let userDefaultsKey = "managedSettings"
    private let deviceActivityCenter = DeviceActivityCenter()
    
    
    
    init() {
        self.managedSettings = ManagedSettings.loadManagedSettings()
        FirestoreMission.loadFirestoreMissions { missions in
            DispatchQueue.main.async {
                self.missions = missions
            }
        }
    }

    
  
    // 파이어베이스 사진 업로드
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

    // 미션 상태 (진행중 -> 인증완료)
    func toVerification(missionId: UUID) {
        if let mission = missions.first(where: { $0.id == missionId }),
           mission.missionStatus == .inProgress {
            FirestoreMission.updateMissionStatus(missionId: mission.id, newStatus: .verificationCompleted)
        }
    }

    
    // 미션 상태 (대기중 -> 진행중)
    func updateMissionStatuses() {
        print("Updating mission statuses...")
        var currentDate = Date()
        
        currentDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        for mission in missions {
            if mission.missionStatus == .beforeStart,
               currentDate >= mission.selectedTime1 {
                FirestoreMission.updateMissionStatus(missionId: mission.id, newStatus: .inProgress)
            }
        }
        FirestoreMission.loadFirestoreMissions { fetchedMissions in
            self.missions = fetchedMissions
        }
    }
    
    // 미션 상태 -> 실패
    func giveUpMission(missionId: UUID) {
        FirestoreMission.updateMissionStatus(missionId: missionId, newStatus: .failure)
        FirestoreMission.loadFirestoreMissions { fetchedMissions in
            self.missions = fetchedMissions
        }
    }
    
    // 미션 완료 (verificationCompleted -> success)
    func completeMission(missionId: UUID) {
        if let mission = missions.first(where: { $0.id == missionId }),
           mission.missionStatus == .verificationCompleted {
            FirestoreMission.updateMissionStatus(missionId: mission.id, newStatus: .success)
            FirestoreMission.loadFirestoreMissions { fetchedMissions in
                self.missions = fetchedMissions
            }
        }
    }

    func missionStorage(forType type: String) -> FirestoreMission? {
        return missions.first { $0.missionType == type }
    }
    
    func createMission(missionType: String) -> FirestoreMission? {
        guard let missionData = missionData.first(where: { $0.missionType == missionType }) else { return nil }
        let newMission = FirestoreMission(id: UUID(),
                                          selectedTime1: self.selectedTime1,
                                          selectedTime2: self.selectedTime2,
                                          currentStore: self.currentStore,
                                          missionType: missionData.missionType,
                                          imageName: missionData.imageName,
                                          missionStatus: MissionStatus.beforeStart)
        self.missions.append(newMission)
        FirestoreMission.saveFirestoreMission(mission: newMission)
        AppGroupMission.saveMissionAppGroup(missions: self.missions.map { MissionTransformer.transform(firestoreMission: $0) })
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
        
        
        
        
//    // 저장된 미션 삭제 메소드 // 딱히 필요없을것 같은데....?
//    func deleteMission(withId id: UUID) {
//        if let index = missions.firstIndex(where: { $0.id == id }) {
//            missions.remove(at: index)
//            MissionStorage.saveMissions(missions: self.missions, userDefaultsManager: userDefaultsManager)
//        }
//    }
    
    // 사진 업로드
    func fetchImageURL(from path: String) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(path)
        
        imageRef.downloadURL { [weak self] url, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                return
            }
            
            if let url = url {
                DispatchQueue.main.async {
                    self?.imageURL = url
                }
            }
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
