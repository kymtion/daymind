
import SwiftUI
import ManagedSettings
import FamilyControls
import DeviceActivity

struct TimeSettingView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    @State private var selectedTime1 = Date()
    @State private var selectedTime2 = Date()
    @State private var isPopupPresented = false
    @State private var showingConfirmation = false
    @State private var showingIntervalError = false
    @State private var showingOverlapError = false
    @State private var createdMission: MissionStorage?
    
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
                        .onChange(of: selectedTime1, perform: { value in
                            updateDate()
                        })
                    }
                    Text("\(formatDate(date: selectedTime1))")
                    
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
                        .onChange(of: selectedTime2, perform: { value in
                            updateDate()
                        })
                    }
                    Text("\(formatDate(date: selectedTime2))")
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
                    
                    if let createdMission = self.missionViewModel.createMission(missionType: mission.missionType) {
                        self.missionViewModel.missionMonitoring(selectedTime1: self.selectedTime1, selectedTime2: self.selectedTime2, missionId: createdMission.id)
                    }
                    
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
    
    func updateDate() {
        let calendar = Calendar.current
        let selectedTime1Components = calendar.dateComponents([.year, .month, .day], from: selectedTime1)
        let selectedTime2Components = calendar.dateComponents([.hour, .minute], from: selectedTime2)
        
        var dateComponents = DateComponents()
        dateComponents.year = selectedTime1Components.year
        dateComponents.month = selectedTime1Components.month
        dateComponents.day = selectedTime1Components.day
        dateComponents.hour = selectedTime2Components.hour
        dateComponents.minute = selectedTime2Components.minute
        
        let newDate = calendar.date(from: dateComponents)!
        
        if newDate < selectedTime1 {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: newDate)!
            selectedTime2 = nextDay
        } else {
            selectedTime2 = newDate
        }
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE, a hh:mm"
        return formatter.string(from: date)
    }
}

struct TimeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        TimeSettingView(mission: missionData[0])
            .environmentObject(MissionViewModel())
    }
}
