
import SwiftUI
import ManagedSettings
import DeviceActivity

struct ActionView: View {
    @EnvironmentObject var missionViewModel: MissionViewModel
    let missionId: UUID
    var mission: MissionStorage? {
        missionViewModel.missions.first { $0.id == missionId }
    }
    
    init(mission: MissionStorage) {
        self.missionId = mission.id
    }
    
    let deviceActivityCenter = DeviceActivityCenter()
    
    var body: some View {
        VStack {
            
            Text("현재 앱 허용 리스트: \(mission?.currentStore ?? "")")
                .foregroundColor(Color.black)
                .font(.system(size: 19))
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.7)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1))
            
          
            
            Button {

                missionViewModel.stopMonitoring(missionId: missionId)
                missionViewModel.giveUpMission(missionId: missionId)
                
                
            } label: {
                Text("포기하기")
                    .padding(10)
                    .font(.system(size: 25, weight: .bold))
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    .background(Color(red: 242 / 255, green: 206 / 255, blue: 102 / 255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

//struct ActionView_Previews: PreviewProvider {
//    static var previews: some View {
//        let missionViewModel = MissionViewModel()
//        let mission = MissionStorage(selectedTime1: Date(), selectedTime2: Date(), currentStore: "Test Store", missionType: "집중")
//        ActionView(mission: mission)
//                    .environmentObject(missionViewModel)
//    }
//}
