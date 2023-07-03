
import SwiftUI
import ManagedSettings
import FamilyControls
import DeviceActivity

struct TimeSettingView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    @State private var selectedTime1 = Date()
    @State private var selectedTime2 = Date()
    @State private var isPopupPresented = false
    @State private var showingConfirmationAlert = false
    @State private var intervalIsShort = false
    @State private var createdMission: MissionStorage?
    
    var mission: Mission
    
    let deviceActivityCenter = DeviceActivityCenter()
    
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
                        let interval = self.selectedTime2.timeIntervalSince(self.selectedTime1)
                        if interval < 900 { // 900 seconds is 15 minutes
                            self.intervalIsShort = true
                        } else {
                            self.intervalIsShort = false
                        }
                        self.showingConfirmationAlert = true
                        
                    } label: {
                        Text("미션 등록")
                            .padding(10)
                            .font(.system(size: 25, weight: .bold))
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .background(Color(red: 242 / 255, green: 206 / 255, blue: 102 / 255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showingConfirmationAlert) {
                        if intervalIsShort {
                            return Alert(title: Text("오류"), message: Text("Interval이 너무 짧습니다. 최소한 15분이상 설정해야합니다."), dismissButton: .default(Text("확인")))
                        } else {
                            return Alert(
                                title: Text("확인"),
                                message: Text("미션을 등록하시겠습니까?"),
                                primaryButton: .default(Text("예")) {
                                    self.missionViewModel.selectedTime1 = self.selectedTime1
                                    self.missionViewModel.selectedTime2 = self.selectedTime2
                                    self.missionViewModel.createMission(missionType: mission.missionType)
                                    
                                    try? deviceActivityCenter.startMonitoring(.focus, during: DeviceActivitySchedule(
                                        intervalStart: DateComponents(hour: 13, minute: 06),
                                        intervalEnd: DateComponents(hour: 23, minute: 59),
                                        repeats: false
                                    )
                                    )
                                },
                                secondaryButton: .cancel()
                            )
                        }
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
