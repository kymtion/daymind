
import SwiftUI
import ManagedSettings
import DeviceActivity

struct ActionView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    @State var showAlert: Bool = false
    
    let missionId: UUID
    var mission: MissionStorage? {
        missionViewModel.missions.first { $0.id == missionId }
    }
    
    init(mission: MissionStorage) {
        self.missionId = mission.id
    }
    
    let deviceActivityCenter = DeviceActivityCenter()
    
    @State var remainingTime: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            
            HStack {
                Text("●")
                    .foregroundColor(Color.green)
                    .font(.system(size: 10))
                    .cornerRadius(10)
                
                Text("\(mission?.currentStore ?? "")")
                    .foregroundColor(Color.black)
                    .font(.system(size: 16))
                
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(Capsule())
            
          
            
            
            Text("🌏")
                .font(.system(size: 100))
            
            
            Text(remainingTime)
                            .font(.system(size: 50, weight: .bold))
                            .onAppear(perform: updateRemainingTime)  // onAppear에 초기 로직 호출 추가
                            .onReceive(timer) { _ in
                                updateRemainingTime()
                            }
            
            
            
           
            
            
            if missionViewModel.missionStatusManager.status(for: missionId) != .verificationCompleted {
                Button {
                    showAlert = true
                } label: {
                    Text("포 기")
                        .padding(10)
                        .font(.system(size: 25, weight: .bold))
                        .frame(width: UIScreen.main.bounds.width * 0.5)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.top)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("경고"),
                        message: Text("포기하면 예치금 환급이 불가능합니다. 포기하시겠습니까?"),
                        primaryButton: .default(Text("예"), action: {
                            missionViewModel.stopMonitoring(missionId: missionId)
                            missionViewModel.giveUpMission(missionId: missionId)
                        }),
                        secondaryButton: .cancel(Text("아니오"))
                    )
                }
            }
            
            
            
            if missionViewModel.missionStatusManager.status(for: missionId) == .verificationCompleted {
                Button {
                    missionViewModel.stopMonitoring(missionId: missionId)
                    missionViewModel.completeMission(missionId: missionId)
                } label: {
                    Text("환 급")
                        .padding(10)
                        .font(.system(size: 25, weight: .bold))
                        .frame(width: UIScreen.main.bounds.width * 0.5)
                        .background(.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            
            Text("차단된 앱을 클릭하여 '미션완료' 버튼을 \n누르면 '환급' 버튼이 생성됩니다.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .opacity(0.7)
                .padding(.bottom, 30)
            
          
            
            VStack(spacing: 12) {
            Text(formatMissionTime())
                    .font(.system(size: 17, weight: .medium))
                Divider()
                Text("예치금 5,000원")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.red)
                    .opacity(0.8)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
    }
    
    func formatMissionTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE a hh:mm"
        let startTimeString = formatter.string(from: mission?.selectedTime1 ?? Date())
        let endTimeString = formatter.string(from: mission?.selectedTime2 ?? Date())
        return "\(startTimeString) ~ \(endTimeString)"
    }
    
    func updateRemainingTime() {
            if let missionEndTime = mission?.selectedTime2 {
                let currentDate = Date()
                let endTime = missionEndTime
                            
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute, .second], from: currentDate, to: endTime)
                            
                if let hour = components.hour, let minute = components.minute, let second = components.second {
                    if hour <= 0 && minute <= 0 && second <= 0 {
                        remainingTime = "00:00:00"
                        timer.upstream.connect().cancel()
                    } else {
                        remainingTime = String(format: "%02d:%02d:%02d", hour, minute, second)
                    }
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
