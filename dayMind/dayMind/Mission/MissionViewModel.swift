
import Foundation
import FirebaseStorage

class MissionViewModel: ObservableObject {
    
    @Published var imageURL: URL?
    
    private let storage = Storage.storage()
    
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
 
    
    
