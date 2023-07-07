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
    func updateDate() {
        let calendar = Calendar.current
        let selectedTime1Components = calendar.dateComponents([.year, .month, .day], from: selectedTime1)
        let selectedTime2Components = calendar.dateComponents([.hour, .minute], from: selectedTime2)
        
        var dateComponents = DateComponents()
        dateComponents.year = selectedTime1Components.year
        dateComponents.month = selectedTime1Components.month
        dateComponents.day = selectedTime1Components.day
        dateComponents.hour = selectedTime2Components.hour
        dateComponents.minute = selectedTime2Components.minute

        let newDate = calendar.date(from: dateComponents)!
        
        if newDate < selectedTime1 {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: newDate)!
            selectedTime2 = nextDay
        } else {
            selectedTime2 = newDate
        }
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE, a hh:mm"
        return formatter.string(from: date)
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
