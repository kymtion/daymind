

import Foundation

struct MissionStorage: Identifiable, Codable {
    var selectedTime1: Date
    var selectedTime2: Date
    var currentStore: String
    
    let id: UUID
    
    init(selectedTime1: Date, selectedTime2: Date, currentStore: String) {
        self.selectedTime1 = selectedTime1
        self.selectedTime2 = selectedTime2
        self.currentStore = currentStore
        self.id = UUID()
    }
}
