//    @Published var categories = Set<ActivityCategory>()
//    @Published var applications = Set<Application>()
//    @Published var webDomains = Set<WebDomain>()

import Foundation
import FirebaseStorage
import SwiftUI
import FamilyControls
import ManagedSettings


class MissionViewModel: ObservableObject {
    
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
        
        func deleteStore(at offsets: IndexSet) {
            savedStores.remove(atOffsets: offsets)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(savedStores) {
                savedStoresData = encoded
            }
        }
    
    //--------ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    
    
    
    
    
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



