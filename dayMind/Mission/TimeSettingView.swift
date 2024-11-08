
import SwiftUI
import ManagedSettings
import FamilyControls
import DeviceActivity

struct TimeSettingView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTime1 = Date()
    @State private var selectedTime2 = Date()
    @State private var isPopupPresented = false
    @State private var showingConfirmation = false
    @State private var showingIntervalError = false
    @State private var showingPastError = false
    @State private var showingOverlapError = false
    @State private var createdMission: FirestoreMission?
    @State private var activeAlert: AlertType?
    
    var mission: Mission? {
        missionViewModel.selectedMission
    }
    
    enum AlertType: Int, Identifiable {
        case intervalError
        case pastError
        case overlapError
        case confirmation
        case missionInProgressError
        case storeNotSelected
        case maxMissionsReached
        
        var id: Int {
            self.rawValue
        }
    }
    
    
    var body: some View {
        
        if let mission = mission {
            VStack {
                HStack {
                    Button {
                        missionViewModel.showTimeSettingView.toggle()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                            Text("Back")
                                .font(.system(size: 18, weight: .regular))
                            Spacer()
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                ScrollView {
                    VStack(spacing: 40) {
                        HStack {
                            Spacer()
                            Text(mission.timeSetting1)
                                .font(.system(size: 20, weight: .bold))
                            Text(":  \(formatDate(date: missionViewModel.selectedTime1))")
                                .font(.system(size: 20, weight: .regular))
                            Spacer()
                        }
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                        
                        DatePicker("", selection: $missionViewModel.selectedTime1,
                                   displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: missionViewModel.selectedTime1, perform: { value in
                            updateDate()
                        })
                        .frame(height: 100)
                        .clipped()
                        
                        HStack {
                            Spacer()
                            Text(mission.timeSetting2)
                                .font(.system(size: 20, weight: .bold))
                            Text(":  \(formatDate(date: missionViewModel.selectedTime2))")
                                .font(.system(size: 20, weight: .regular))
                            Spacer()
                        }
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding(.horizontal, 15)
                        
                        DatePicker("", selection: $missionViewModel.selectedTime2,
                                   displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: missionViewModel.selectedTime2, perform: { value in
                            updateDate()
                        })
                        .frame(height: 100)
                        .clipped()
                        
                        VStack(spacing: 30) {
                            let interval = missionViewModel.selectedTime2.timeIntervalSince(missionViewModel.selectedTime1)
                            let totalMinutes = Int((interval / 60).rounded())
                            let hours = totalMinutes / 60
                            let minutes = totalMinutes % 60
                            Text("총 시간 \(hours)시간 \(minutes)분")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            
                            VStack(spacing: 20) {
                                Button {
                                    self.isPopupPresented = true
                                } label: {
                                    Text("앱 허용 리스트 : \(missionViewModel.currentStore)")
                                        .font(.system(size: 18, weight: .medium))
                                        .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 0.2))
                                        .shadow(color: Color.gray.opacity(0.15), radius: 2, x: 0, y: 0)
                                    
                                }
                                .sheet(isPresented: $isPopupPresented) {
                                    AllowListView(isPopupPresented: $isPopupPresented)
                                        .environmentObject(missionViewModel)
                                }
                                Text("차단에서 제외할 앱 리스트를 설정하세요.")
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: 15, weight: .regular))
                                    .opacity(0.8)
                            }
                            
                            
                            BlueButton(title: "다 음") {
                                if missionViewModel.currentStore.isEmpty {
                                    self.activeAlert = .storeNotSelected
                                } else {
                                    
                                    // 오늘 날짜와 같은 미션의 개수 확인
                                    let calendar = Calendar.current
                                    let today = calendar.startOfDay(for: Date())
                                    let todayMissionsCount = missionViewModel.missions.filter { mission in
                                        let missionStartDate = calendar.startOfDay(for: mission.selectedTime1)
                                        return missionStartDate == today
                                    }.count
                                    // 숫자는 5로 맞춰놓아야함! 그래야 5개 이상부터 알림이 표시됨
                                    if todayMissionsCount > 5 {
                                        self.activeAlert = .maxMissionsReached
                                    } else {
                                        let interval = missionViewModel.selectedTime2.timeIntervalSince(missionViewModel.selectedTime1)
                                        if interval < 15 * 60 {
                                            self.activeAlert = .intervalError
                                            
                                        } else {
                                            //시작 시간이 현재 시간보다 과거일 경우 오류메시지 뜸
                                            let calendar = Calendar.current
                                            let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
                                            let selectedTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: missionViewModel.selectedTime1)
                                            let nowDateMinute = calendar.date(from: nowComponents)!
                                            let selectedDateMinute = calendar.date(from: selectedTimeComponents)!
                                            if selectedDateMinute < nowDateMinute {
                                                self.activeAlert = .pastError
                                            } else {
                                                // 미션 상태가 진행중인데 종료시각이 이미 지난 경우 오류메시지 뜸
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
                                                    let currentStartTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: missionViewModel.selectedTime1)
                                                    let currentEndTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: missionViewModel.selectedTime2)
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
                                }
                            }
                            .alert(item: $activeAlert) { alertType in
                                switch alertType {
                                case .maxMissionsReached:
                                    return Alert(title: Text("알림"), message: Text("하루 최대 5개까지만 미션등록이 가능합니다."), dismissButton: .default(Text("확인")))
                                case .storeNotSelected:
                                    return Alert(title: Text("알림"), message: Text("앱 허용 리스트를 선택하세요"), dismissButton: .default(Text("확인")))
                                case .intervalError:
                                    return Alert(title: Text("경고"), message: Text("시간 간격이 너무 짧습니다. \n최소한 15분이상 설정해야합니다."), dismissButton: .default(Text("확인")))
                                case .pastError:
                                    return Alert(title: Text("경고"), message: Text("시작 시간이 현재 시간 이후로 설정 해야합니다."), dismissButton: .default(Text("확인")))
                                case .missionInProgressError:
                                    return Alert(title: Text("경고"), message: Text("기존 미션을 완료해야 미션 등록이 가능합니다."), dismissButton: .default(Text("확인")))
                                case .overlapError:
                                    return Alert(title: Text("경고"), message: Text("선택한 시간대에 이미 등록된 미션이 있습니다."), dismissButton: .default(Text("확인")))
                                case .confirmation:
                                    return Alert(title: Text("확인"), message: Text("설정을 모두 완료하셨나요?"), primaryButton: .default(Text("예"), action: {
                                        missionViewModel.showPaymentView = true
                                        
                                    }), secondaryButton: .cancel())
                                }
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $missionViewModel.showPaymentView) {
                PaymentView()
                    .environmentObject(missionViewModel)
            }
            .onAppear {
                FirestoreMission.listenForChanges { missions in
                    self.missionViewModel.missions = missions
                }
            }
            
        }
    }
    
    
    
    // 시간을 입력하면 알맞은 날짜로 시간을 변환시켜줌(하루를 더해주거나 빼줌)
    func updateDate() {
        let calendar = Calendar.current
        let selectedTime1Components = calendar.dateComponents([.year, .month, .day], from: missionViewModel.selectedTime1)
        let selectedTime2Components = calendar.dateComponents([.hour, .minute], from: missionViewModel.selectedTime2)
        
        var dateComponents = DateComponents()
        dateComponents.year = selectedTime1Components.year
        dateComponents.month = selectedTime1Components.month
        dateComponents.day = selectedTime1Components.day
        dateComponents.hour = selectedTime2Components.hour
        dateComponents.minute = selectedTime2Components.minute
        
        let newDate = calendar.date(from: dateComponents)!
        
        if newDate < missionViewModel.selectedTime1 {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: newDate)!
            missionViewModel.selectedTime2 = nextDay
        } else {
            missionViewModel.selectedTime2 = newDate
        }
    }
    // 날짜를 사용자가 이해하기 쉽게 포맷을 변경해줌
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE, a hh:mm"
        return formatter.string(from: date)
    }
}

//struct TimeSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeSettingView(mission: missionData[0])
//            .environmentObject(MissionViewModel())
//    }
//}
