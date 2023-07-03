
import Foundation
import FamilyControls
import ManagedSettings

struct ManagedSettings {
    
    var managedSettings: [ManagedSettingsStore.Name: FamilyActivitySelection]
    
    init(managedSettings: [ManagedSettingsStore.Name: FamilyActivitySelection]) {
        self.managedSettings = managedSettings
    }
    
//    static func saveManagedSettings(settings: [ManagedSettingsStore.Name: FamilyActivitySelection]) {
//        let encoder = JSONEncoder()
//        let transformedDictionary = settings.mapKeys { $0.rawValue }
//        do {
//            let data = try encoder.encode(transformedDictionary)
//            UserDefaults.standard.set(data, forKey: "managedSettings")
//        } catch {
//            print("Error encoding managedSettings: \(error)")
//        }
//    }
//
//    static func loadManagedSettings() -> [ManagedSettingsStore.Name: FamilyActivitySelection] {
//        let decoder = JSONDecoder()
//        if let savedData = UserDefaults.standard.data(forKey: "managedSettings") {
//            do {
//                let dictionary = try decoder.decode([String: FamilyActivitySelection].self, from: savedData)
//                return dictionary.mapKeys { ManagedSettingsStore.Name(rawValue: $0) }
//            } catch {
//                print("Error decoding managedSettings: \(error)")
//            }
//        }
//        return [:]
//    }
//}

    static func saveManagedSettings(settings: [ManagedSettingsStore.Name: FamilyActivitySelection]) {
            let encoder = JSONEncoder()
            let transformedDictionary = settings.mapKeys { $0.rawValue }
            do {
                let data = try encoder.encode(transformedDictionary)
                UserDefaults(suiteName: "group.kr.co.daymind.daymind")?.set(data, forKey: "managedSettings")
            } catch {
                print("Error encoding managedSettings: \(error)")
            }
        }
        
        static func loadManagedSettings() -> [ManagedSettingsStore.Name: FamilyActivitySelection] {
            let decoder = JSONDecoder()
            if let savedData = UserDefaults(suiteName: "group.kr.co.daymind.daymind")?.data(forKey: "managedSettings") {
                do {
                    let dictionary = try decoder.decode([String: FamilyActivitySelection].self, from: savedData)
                    return dictionary.mapKeys { ManagedSettingsStore.Name(rawValue: $0) }
                } catch {
                    print("Error decoding managedSettings: \(error)")
                }
            }
            return [:]
        }
    }
