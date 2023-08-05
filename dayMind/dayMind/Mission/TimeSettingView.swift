
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
    @State private var showingPastError = false
    @State private var showingOverlapError = false
    @State private var createdMission: FirestoreMission?
    @State private var activeAlert: AlertType?
    @State private var navigateToPaymentView = false
    
    
    var mission: Mission
    
    
    enum AlertType: Int, Identifiable {
        case intervalError
        case pastError
        case overlapError
        case confirmation
        case missionInProgressError
        case storeNotSelected
        
        var id: Int {
            self.rawValue
        }
    }
    
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 40) {
                    
                    HStack {
                        Spacer()
                        Text(mission.timeSetting1)
                            .font(.system(size: 20, weight: .bold))
                        Text(":  \(formatDate(date: selectedTime1))")
                            .font(.system(size: 20, weight: .regular))
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 40)
                    
                    DatePicker("", selection: $selectedTime1,
                               displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: selectedTime1, perform: { value in
                        updateDate()
                    })
                    .frame(height: 100)
                    .clipped()
                    
                    HStack {
                        Spacer()
                        Text(mission.timeSetting2)
                            .font(.system(size: 20, weight: .bold))
                        Text(":  \(formatDate(date: selectedTime2))")
                            .font(.system(size: 20, weight: .regular))
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    DatePicker("", selection: $selectedTime2,
                               displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: selectedTime2, perform: { value in
                        updateDate()
                    })
                    .frame(height: 100)
                    .clipped()
                    
                    
                    
                    VStack(spacing: 20) {
                        Button {
                            self.isPopupPresented = true
                        } label: {
                            Text("앱 허용 리스트 : \(missionViewModel.currentStore)")
                                .foregroundColor(Color.black)
                                .font(.system(size: 18, weight: .medium))
                                .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.5), lineWidth: 0.3))
                                .shadow(color: Color.gray.opacity(0.15), radius: 2, x: 0, y: 0)
                                
                        }
                        .sheet(isPresented: $isPopupPresented) {
                            AllowListView(isPopupPresented: $isPopupPresented)
                                .environmentObject(missionViewModel)
                        }
                        Text("차단에서 제외할 앱 리스트를 설정하세요.")
                            .opacity(0.7)
                            .font(.system(size: 15, weight: .regular))
                    }
                    
                    
                    
                    
                    
                    
                    
                    Button {
                        if missionViewModel.currentStore.isEmpty {
                            self.activeAlert = .storeNotSelected
                        } else {
                            
                            let interval = self.selectedTime2.timeIntervalSince(self.selectedTime1)
                            if interval < 15 * 60 {
                                self.activeAlert = .intervalError
                                
                            } else {
                                let calendar = Calendar.current
                                let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
                                let selectedTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedTime1)
                                let nowDateMinute = calendar.date(from: nowComponents)!
                                let selectedDateMinute = calendar.date(from: selectedTimeComponents)!
                                if selectedDateMinute < nowDateMinute {
                                    self.activeAlert = .pastError
                                } else {
                                    let inProgressMissions = missionViewModel.missions.filter {
                                        $0.missionStatus == .inProgress
                                    }
                                    for mission in inProgressMissions {
                                        let missionEndTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: mission.selectedTime2)
                                        let missionEndTime = calendar.date(from: missionEndTimeComponents)!
                                        if missionEndTime < nowDateMinute {
                                            self.activeAlert = .missionInProgressError
                                            return
                                        }
                                    }
                                    
                                    // 미션 상태가 진행중 또는 대기중인 미션들 중에서 미션 시간이 겹치는게 있는지 파악해줌
                                    let overlappingMissions = missionViewModel.missions.filter { mission in
                                        return (mission.missionStatus == .beforeStart || mission.missionStatus == .inProgress)
                                    }
                                    for mission in overlappingMissions {
                                        let currentStartTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedTime1)
                                        let currentEndTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedTime2)
                                        let missionStartTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: mission.selectedTime1)
                                        let missionEndTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: mission.selectedTime2)
                                        
                                        let currentStartTime = calendar.date(from: currentStartTimeComponents)!
                                        let currentEndTime = calendar.date(from: currentEndTimeComponents)!
                                        let missionStartTime = calendar.date(from: missionStartTimeComponents)!
                                        let missionEndTime = calendar.date(from: missionEndTimeComponents)!
                                        
                                        if (missionEndTime >= currentStartTime && missionStartTime <= currentEndTime) {
                                            self.activeAlert = .overlapError
                                            return
                                        }
                                    }
                                    self.activeAlert = .confirmation
                                }
                            }
                        }
                    } label: {
                        Text("미션 등록")
                            .padding(10)
                            .font(.system(size: 22, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width * 0.4)
                            .background(.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            
                    }
                    .alert(item: $activeAlert) { alertType in
                        switch alertType {
                        case .storeNotSelected:
                            return Alert(title: Text("알림"), message: Text("앱 허용 리스트를 선택하세요"), dismissButton: .default(Text("확인")))
                        case .intervalError:
                            return Alert(title: Text("경고"), message: Text("시간 간격이 너무 짧습니다. 최소한 15분이상 설정해야합니다."), dismissButton: .default(Text("확인")))
                        case .pastError:
                            return Alert(title: Text("경고"), message: Text("시작 시간이 현재 시간 이후로 설정 해야합니다."), dismissButton: .default(Text("확인")))
                        case .missionInProgressError:
                            return Alert(title: Text("경고"), message: Text("기존 미션을 완료해야 미션 등록이 가능합니다."), dismissButton: .default(Text("확인")))
                        case .overlapError:
                            return Alert(title: Text("경고"), message: Text("선택한 시간대에 이미 등록된 미션이 있습니다."), dismissButton: .default(Text("확인")))
                        case .confirmation:
                            return Alert(title: Text("확인"), message: Text("미션을 등록하시겠습니까?"), primaryButton: .default(Text("예"), action: {
                                self.navigateToPaymentView = true
                                
                            }), secondaryButton: .cancel())
                        }
                    }
                    NavigationLink(destination: PaymentView(), isActive: $navigateToPaymentView) {
                        EmptyView()
                    }
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
