
import SwiftUI
import ManagedSettings
import FamilyControls
import DeviceActivity

struct TimeSettingView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    @State private var selectedTime1 = Date()
    @State private var selectedTime2 = Date()
    @State private var isPopupPresented = false
    
    var mission: Mission
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading) {
                        Text(mission.timeSetting1)
                            .font(.system(size: 25, weight: .bold))
                        
                        DatePicker("", selection: $selectedTime1,
                                   displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 10)
                    
                    VStack(alignment: .leading) {
                        Text(mission.timeSetting2)
                            .font(.system(size: 25, weight: .bold))
                        
                        DatePicker("", selection: $selectedTime2,
                                   displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 10)
                    Spacer()
                    Button {
                        self.isPopupPresented = true
                    } label: {
                        Text("현재 앱 허용 리스트: \(missionViewModel.currentStore)")
                            .foregroundColor(Color.black)
                            .font(.system(size: 19))
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1))
                    }
                    .sheet(isPresented: $isPopupPresented) {
                        AllowListView(isPopupPresented: $isPopupPresented)
                            .environmentObject(missionViewModel)
                    }
                    Spacer()
                    Button {
                           self.missionViewModel.selectedTime1 = self.selectedTime1
                           self.missionViewModel.selectedTime2 = self.selectedTime2
                           self.missionViewModel.createMission(missionType: mission.missionType)
                    } label: {
                        Text("미션 등록")
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
    }
}


struct TimeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSettingView(mission: missionData[0])
            .environmentObject(MissionViewModel())
    }
}
