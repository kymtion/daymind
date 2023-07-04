
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
    
    init() {
           self.managedSettings = ManagedSettings.loadManagedSettings()
           self.missions = MissionStorage.loadMissions()
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
        // Save the missions.
        MissionStorage.saveMissions(missions: self.missions)
        return newMission
    }
    
    
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
        } catch {
            print("Error starting device activity monitoring: \(error)")
        }
    }
    
    func stopMonitoring(missionId: UUID) {
        let activityName = DeviceActivityName(rawValue: missionId.uuidString)
        deviceActivityCenter.stopMonitoring([activityName])
        print("Stopping monitoring for \(missionId.uuidString)")
    }
    
    func isOverlapWithExistingMissions(startTime: Date, endTime: Date) -> String? {
        let updatedEndTime = endTime < startTime
            ? Calendar.current.date(byAdding: .day, value: 1, to: endTime)!
            : endTime
        for existingMission in missions {
            // Two intervals overlap if the start of one is less than the end of the other one and vice versa.
            let existingMissionStartTime = existingMission.selectedTime1
            let existingMissionEndTime = existingMission.selectedTime2 < existingMission.selectedTime1
                ? Calendar.current.date(byAdding: .day, value: 1, to: existingMission.selectedTime2)!
                : existingMission.selectedTime2
            if max(startTime, existingMissionStartTime) < min(updatedEndTime, existingMissionEndTime) {
                return "선택한 시간대에 이미 등록된 미션이 있습니다."
            }
        }

        return nil
    }

    
    func updateTimes(selectedTime1: Date, selectedTime2: Date) -> (Date, Date, String?) {
        var newTime1 = selectedTime1
        var newTime2 = selectedTime2
        let minimumInterval = 900.0 // 900 seconds is 15 minutes

        // 1. selectedTime1 은 항상 현재 시간보다 미래여야 한다
        if newTime1 < Date() {
            newTime1 = Calendar.current.date(byAdding: .day, value: 1, to: newTime1)!
        }

        // 2. selectedTime1은 selectedTime2 보다 항상 과거여야한다
        if newTime2 < newTime1 {
            newTime2 = Calendar.current.date(byAdding: .day, value: 1, to: newTime2)!
        }

        // 3. selectedTime1와 selectedTime2의 시간 차이는 15분 이상이어야 한다
        let interval = newTime2.timeIntervalSince(newTime1)
        if interval < minimumInterval {
            return (newTime1, newTime2, "시간 간격이 너무 짧습니다. 최소한 15분이상 설정해야합니다.")
        }

        return (newTime1, newTime2, nil)
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

    
