
import Foundation
import FirebaseStorage
import SwiftUI
import FamilyControls
import ManagedSettings


class MissionViewModel: ObservableObject {
    @Published var currentStore: String = ""
    @Published var imageURL: URL?
    @Published var savedStores: [String]
    @AppStorage("savedStores") var savedStoresData: Data?
    
    private let storage = Storage.storage()
    
    //--------ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    
    init() {
        self.savedStores = []
        if let data = savedStoresData {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([String].self, from: data) {
                self.savedStores = decoded
            }
        } else {
            self.savedStores = []
        }
    }
    
    func addStore(_ store: ManagedSettingsStore.Name) {
        self.savedStores.append(store.rawValue)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(savedStores) {
            savedStoresData = encoded
        }
    }
    
    func deleteStore(storeName: String) {
        if let index = self.savedStores.firstIndex(of: storeName) {
            self.savedStores.remove(at: index)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(savedStores) {
                savedStoresData = encoded
            }
        }
    }
    func updateStoreName(oldName: String, newName: String) {
        if let index = self.savedStores.firstIndex(of: oldName) {
            self.savedStores[index] = newName
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(savedStores) {
                savedStoresData = encoded
            }
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
}
