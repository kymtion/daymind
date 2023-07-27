
import SwiftUI
import ManagedSettings
import DeviceActivity

struct ActionView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    @State var showAlert: Bool = false
    @State var remainingTime: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let missionId: UUID
    var mission: MissionStorage? {
        missionViewModel.missions.first { $0.id == missionId }
    }
    
    // CameraView의 상태 변수들
    @State private var showCamera = false
    @State private var image: UIImage?
    @State private var showConfirmButton = false
    @State private var showConfirmation = false
    
    init(mission: MissionStorage) {
        self.missionId = mission.id
    }
    
    let deviceActivityCenter = DeviceActivityCenter()
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 35) {
                Text("예치금: 5,000원")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(.red)
                    .opacity(0.8)
                
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
                
                VStack {
                    Text(remainingTime)
                        .font(.system(size: 50, weight: .medium))
                        .onAppear(perform: updateRemainingTime)  // onAppear에 초기 로직 호출 추가
                        .onReceive(timer) { _ in
                            updateRemainingTime()
                        }
                    
                    Text(formatMissionTime())
                        .font(.system(size: 12, weight: .light))
                    
                }
                
                //미션 타입 -> 수면
                VStack(spacing: 20) {
                    if mission?.missionType == "수면" {
                        let timeComponents = remainingTime.split(separator: ":").map { Int($0) }
                        if timeComponents.count == 3,
                           let hour = timeComponents[0],
                           let minute = timeComponents[1],
                           let second = timeComponents[2] {
                            let totalSeconds = hour * 3600 + minute * 60 + second
                            if totalSeconds > 0 && totalSeconds < 3600 {
                                Button {
                                    if missionViewModel.missionStatusManager.status(for: missionId) == .verificationCompleted {
                                        self.showAlert = true
                                    } else {
                                        self.showCamera = true
                                    }
                                } label: {
                                    Text("인 증")
                                        .padding(10)
                                        .font(.system(size: 25, weight: .bold))
                                        .frame(width: UIScreen.main.bounds.width * 0.5)
                                        .background(.green)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text("알림"), message: Text("이미 인증을 완료하셨습니다."), dismissButton: .default(Text("확인")))
                                }
                                .fullScreenCover(isPresented: $showCamera) {
                                    ImagePicker(image: self.$image) { selectedImage in
                                        self.image = selectedImage
                                        self.showCamera = false
                                        if selectedImage != nil {
                                            DispatchQueue.main.async {
                                                self.showConfirmation = true
                                            }
                                        }
                                    }
                                    .edgesIgnoringSafeArea(.all)  // Add this line
                                    .background(Color.black) // Add this line
                                }
                                .fullScreenCover(isPresented: $showConfirmation) {
                                    VStack {
                                        if let img = self.image {
                                            Image(uiImage: img)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: UIScreen.main.bounds.width * 1)
                                                .padding(.bottom, 30)
                                            
                                            Text("인증을 완료하시겠습니까?")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.bottom, 20)
                                            
                                            Button {
                                                // 이미지를 관리자 페이지에 업로드하는 코드를 넣으세요.
                                                self.showConfirmation = false
                                                missionViewModel.toVerification(missionId: self.missionId)
                                            } label: {
                                                Text("인 증")
                                                    .padding(10)
                                                    .font(.system(size: 25, weight: .bold))
                                                    .frame(width: UIScreen.main.bounds.width * 0.5)
                                                    .background(.green)
                                                    .foregroundColor(.white)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black)
                                }
                            }
                        }
                    }
                    
                    if mission?.missionType == "수면" {
                        Text("남은 시간이 1시간 이하일 때\n인증 버튼이 활성화됩니다.")
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                    }
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
                
                //미션 타입 -> 집중
                if missionViewModel.missionStatusManager.status(for: missionId) == .verificationCompleted && mission?.missionType == "집중" {
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
                if mission?.missionType == "집중" {
                    Text("차단된 앱을 클릭하여 '미션완료' 버튼을 \n누르면 '환급' 버튼이 생성됩니다.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .opacity(0.7)
                        .padding(.bottom, 30)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    func didFinishPicking(_ image: UIImage?) {
        self.showConfirmButton = (image != nil)
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
                    
                    // 남은 시간이 00:00:00 이고, 미션 타입이 "수면"이며, 미션 상태가 inProgress일 경우
                    if mission?.missionType == "수면" && missionViewModel.missionStatusManager.status(for: missionId) == .inProgress {
                        // 자동으로 포기 버튼이 눌린것 처럼 작동됨.
                        missionViewModel.stopMonitoring(missionId: missionId)
                        missionViewModel.giveUpMission(missionId: missionId)
                    }
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
