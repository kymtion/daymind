
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
    
    init() {
           self.managedSettings = ManagedSettings.loadManagedSettings()
           self.missions = MissionStorage.loadMissions()
    }
    
//    let deviceActivityCenter = DeviceActivityCenter()
    
    
    func missionStorage(forType type: String) -> MissionStorage? {
        return missions.first { $0.missionType == type }
    }
    
    
    func createMission(missionType: String) {
        
        let newMission = MissionStorage(selectedTime1: self.selectedTime1,
                                           selectedTime2: self.selectedTime2,
                                           currentStore: self.currentStore,
                                           missionType: missionType)
        self.missions.append(newMission)
        // Save the missions.
        MissionStorage.saveMissions(missions: self.missions)
        
    }

    
//    func scheduleMissionMonitoring(mission: MissionStorage, time1: Date, time2: Date, completion: (DeviceActivityName) -> Void) {
//        self.selectedTime1 = time1
//        self.selectedTime2 = time2
//        
//        let calendar = Calendar.current
//        let startHour = calendar.component(.hour, from: time1)
//        let startMinute = calendar.component(.minute, from: time1)
//        let endHour = calendar.component(.hour, from: time2)
//        let endMinute = calendar.component(.minute, from: time2)
//        
//        let schedule = DeviceActivitySchedule(
//            intervalStart: DateComponents(hour: 23, minute: 26),
//            intervalEnd: DateComponents(hour: 23, minute: 50),
//            repeats: true
//        )
//        
////        let activityName = DeviceActivityName(rawValue: mission.id.uuidString)
//        
//        
//        do {
//            try self.deviceActivityCenter.startMonitoring(.focus, during: schedule)
//            print("Start monitoring for activityName")
//            
//        } catch DeviceActivityCenter.MonitoringError.unauthorized {
//            print("Monitoring stopped due to lack of permissions.")
//            // 모니터링 중지
//            self.deviceActivityCenter.stopMonitoring([.focus])
//            // 필요한 추가 처리 수행
//            
//        } catch {
//            print("Failed to start monitoring: \(error)")
//        }
//    }
    

    
    // 저장된 미션 삭제 메소드
    func deleteMission(withId id: UUID) {
        if let index = missions.firstIndex(where: { $0.id == id }) {
            missions.remove(at: index)
            MissionStorage.saveMissions(missions: self.missions)
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

    
