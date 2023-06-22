
import Foundation
import FirebaseStorage
import SwiftUI
import FamilyControls
import ManagedSettings

class MissionViewModel: ObservableObject {
    @Published var currentStore: String = ""
    @Published var imageURL: URL?
    
    @Published var selectedTime1: Date = Date()
    @Published var selectedTime2: Date = Date()
    @Published var managedSettings: [ManagedSettingsStore.Name: FamilyActivitySelection] = [:]
    
   
    
    private let storage = Storage.storage()

    private let userDefaultsKey = "managedSettings"
    
    init() {
            loadManagedSettings()
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
