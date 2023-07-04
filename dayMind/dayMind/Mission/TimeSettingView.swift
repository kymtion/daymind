
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
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertType: AlertType?
    
    var mission: Mission
    
    enum AlertType {
        case intervalError, overlapError, confirmation
    }
    
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
                        let (updatedTime1, updatedTime2, intervalErrorMessage) = self.missionViewModel.updateTimes(selectedTime1: self.selectedTime1, selectedTime2: self.selectedTime2)
                        
                        if let intervalErrorMessage = intervalErrorMessage {
                            self.alertTitle = "오류"
                            self.alertMessage = intervalErrorMessage
                            self.alertType = .intervalError
                        } else if let overlapErrorMessage = self.missionViewModel.isOverlapWithExistingMissions(startTime: self.selectedTime1, endTime: self.selectedTime2) {
                            self.alertTitle = "오류"
                            self.alertMessage = overlapErrorMessage
                            self.alertType = .overlapError
                        } else {
                            self.selectedTime1 = updatedTime1
                            self.selectedTime2 = updatedTime2
                            self.alertTitle = "확인"
                            self.alertMessage = "미션을 등록하시겠습니까?"
                            self.alertType = .confirmation
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
                    .alert(isPresented: Binding<Bool>(
                        get: { self.alertType != nil },
                        set: { if $0 == false { self.alertType = nil } }
                    )) {
                        switch alertType {
                        case .intervalError, .overlapError:
                            return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                        case .confirmation:
                            return Alert(
                                title: Text(alertTitle),
                                message: Text(alertMessage),
                                primaryButton: .default(Text("예")) {
                                    self.missionViewModel.selectedTime1 = self.selectedTime1
                                    self.missionViewModel.selectedTime2 = self.selectedTime2
                                    
                                    if let createdMission = self.missionViewModel.createMission(missionType: mission.missionType) {
                                        self.missionViewModel.missionMonitoring(selectedTime1: self.selectedTime1, selectedTime2: self.selectedTime2, missionId: createdMission.id)
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        case .none:
                            return Alert(title: Text("")) // This should never be shown
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
