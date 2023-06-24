
import Foundation
import FirebaseStorage
import FamilyControls
import ManagedSettings

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
        loadManagedSettings()
        loadMissions()
    }
    
    func createMission() {
        let mission = MissionStorage(selectedTime1: self.selectedTime1,
                                     selectedTime2: self.selectedTime2,
                                     currentStore: self.currentStore)
        
        missions.append(mission)
                    
        // Save the missions.
        saveMissions()
    }
    
    private func saveMissions() {
              let encoder = JSONEncoder()
              do {
                  let data = try encoder.encode(missions)
                  UserDefaults.standard.set(data, forKey: "missions")
              } catch {
                  print("Error encoding missions: \(error)")
              }
          }

    
    private func loadMissions() {
               let decoder = JSONDecoder()
               if let savedData = UserDefaults.standard.data(forKey: "missions") {
                   do {
                       missions = try decoder.decode([MissionStorage].self, from: savedData)
                   } catch {
                       print("Error decoding missions: \(error)")
                   }
               }
           }
    
    func deleteMission(withId id: UUID) {
        if let index = missions.firstIndex(where: { $0.id == id }) {
            missions.remove(at: index)
            saveMissions()
        }
    }
       
    func startBlockingApps(for missionId: UUID) {
        guard let mission = missions.first(where: { $0.id == missionId }) else { return }
        let currentStoreName = ManagedSettingsStore.Name(rawValue: mission.currentStore)
          if let store = managedSettings[currentStoreName] {
                  let selectedAppTokens = store.applicationTokens
                  let selectedWebDomainTokens = store.webDomainTokens
  
                  let selectedList = ManagedSettingsStore(named: currentStoreName)
                  selectedList.shield.applicationCategories = .all(except: selectedAppTokens)
                  selectedList.shield.webDomainCategories = .all(except: selectedWebDomainTokens)
              }
          }
  
          func stopBlockingApps(for missionId: UUID) {
              guard let mission = missions.first(where: { $0.id == missionId }) else { return }
              let currentStoreName = ManagedSettingsStore.Name(rawValue: mission.currentStore)
              let selectedList = ManagedSettingsStore(named: currentStoreName)
              selectedList.clearAllSettings()
          }
      

    
    
       
    func addStore(_ store: String, selection: FamilyActivitySelection) {
        let storeName = ManagedSettingsStore.Name(rawValue: store)
        self.managedSettings[storeName] = selection
        saveManagedSettings()
    }
    
    func deleteStore(storeName: String) {
        let storeName = ManagedSettingsStore.Name(rawValue: storeName)
        self.managedSettings.removeValue(forKey: storeName)
        saveManagedSettings()
    }
    
    func updateStoreName(oldName: String, newName: String) {
        let oldStoreName = ManagedSettingsStore.Name(rawValue: oldName)
        let newStoreName = ManagedSettingsStore.Name(rawValue: newName)
        
        if let oldValue = self.managedSettings[oldStoreName] {
            self.managedSettings.removeValue(forKey: oldStoreName)
            self.managedSettings[newStoreName] = oldValue
            saveManagedSettings()
        }
    }
    
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
    
    private func saveManagedSettings() {
        let encoder = JSONEncoder()
        let transformedDictionary = managedSettings.mapKeys { $0.rawValue }
        do {
            let data = try encoder.encode(transformedDictionary)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding managedSettings: \(error)")
        }
    }
    
    private func loadManagedSettings() {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let dictionary = try decoder.decode([String: FamilyActivitySelection].self, from: savedData)
                managedSettings = dictionary.mapKeys { ManagedSettingsStore.Name(rawValue: $0) }
            } catch {
                print("Error decoding managedSettings: \(error)")
            }
        }
    }
}
