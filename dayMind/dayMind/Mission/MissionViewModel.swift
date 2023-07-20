import Foundation
import FirebaseStorage
import FamilyControls
import ManagedSettings
import DeviceActivity

class MissionViewModel: ObservableObject {
    @Published var currentStore: String = ""
    @Published var imageURL: URL?
    @Published var selectedTime1: Date = Date()
    @Published var selectedTime2: Date = Date()
    @Published var managedSettings: [ManagedSettingsStore.Name: FamilyActivitySelection] = [:]
    @Published var missions: [MissionStorage] = []
    
    private let storage = Storage.storage()
    private let userDefaultsKey = "managedSettings"
    private let deviceActivityCenter = DeviceActivityCenter()
    
    @Published var missionStatusManager = MissionStatusManager()
    
    private let userDefaultsManager = UserDefaultsManager.shared
    
    init() {
        self.managedSettings = ManagedSettings.loadManagedSettings()
        self.missions = MissionStorage.loadMissions(userDefaultsManager: userDefaultsManager)
        if let loadedStatusManager = MissionStatusManager.loadStatuses(userDefaultsManager: userDefaultsManager) {
            self.missionStatusManager = loadedStatusManager
        }
        setupObservation()
    }
    
    private func setupObservation() {
        _ = $missionStatusManager.sink { [weak self] _ in
            guard let self = self else { return }
            self.missions = MissionStorage.loadMissions(userDefaultsManager: self.userDefaultsManager)
        }
    }

    
    

    
    // 미션 상태 (대기중 -> 진행중)
    func updateMissionStatuses() {
        print("Updating mission statuses...")
        var currentDate = Date()
        
        currentDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        for mission in missions {
            let missionStatus = missionStatusManager.status(for: mission.id) ?? .beforeStart
            if missionStatus == .beforeStart,
               currentDate >= mission.selectedTime1 {
                missionStatusManager.updateStatus(for: mission.id, to: .inProgress)
            }
        }
        MissionStatusManager.saveStatuses(statusManager: missionStatusManager, userDefaultsManager: userDefaultsManager)
        self.missions = MissionStorage.loadMissions(userDefaultsManager: userDefaultsManager)
    }
    
    // 미션 상태 -> 실패
    func giveUpMission(missionId: UUID) {
        // Change mission status to failure
        self.missionStatusManager.updateStatus(for: missionId, to: .failure)
        MissionStatusManager.saveStatuses(statusManager: missionStatusManager, userDefaultsManager: userDefaultsManager)
        self.missions = MissionStorage.loadMissions(userDefaultsManager: userDefaultsManager)
    }
    
    // 미션 완료 (verificationCompleted -> success)
    func completeMission(missionId: UUID) {
        if let missionStatus = self.missionStatusManager.status(for: missionId),
           missionStatus == .verificationCompleted {
            self.missionStatusManager.updateStatus(for: missionId, to: .success)
            MissionStatusManager.saveStatuses(statusManager: missionStatusManager, userDefaultsManager: userDefaultsManager)
            self.missions = MissionStorage.loadMissions(userDefaultsManager: userDefaultsManager)
        }
    }
    




    func missionStorage(forType type: String) -> MissionStorage? {
        return missions.first { $0.missionType == type }
    }
    
    func createMission(missionType: String) -> MissionStorage? {
        guard let missionData = missionData.first(where: { $0.missionType == missionType }) else { return nil }
        let newMission = MissionStorage(selectedTime1: self.selectedTime1,
                                           selectedTime2: self.selectedTime2,
                                        currentStore: self.currentStore,
                                        missionType: missionData.missionType,
                                        imageName: missionData.imageName)
        self.missions.append(newMission)
        self.missionStatusManager.updateStatus(for: newMission.id, to: .beforeStart)
        MissionStorage.saveMissions(missions: self.missions, userDefaultsManager: userDefaultsManager)
        MissionStatusManager.saveStatuses(statusManager: self.missionStatusManager, userDefaultsManager: userDefaultsManager)
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
        
        
        
        
    // 저장된 미션 삭제 메소드
    func deleteMission(withId id: UUID) {
        if let index = missions.firstIndex(where: { $0.id == id }) {
            missions.remove(at: index)
            MissionStorage.saveMissions(missions: self.missions, userDefaultsManager: userDefaultsManager)
        }
    }
    
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
