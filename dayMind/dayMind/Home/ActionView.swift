
import SwiftUI
import ManagedSettings
import DeviceActivity

struct ActionView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var showAlert2: Bool = false // 포기하면 예치금 환급이 불가능합니다. 포기하시겠습니까?
    @State private var alertType: AlertType?
    @State var remainingTime: String = ""
    @Binding var selectedMissionId: UUID?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let missionId: UUID
    var mission: FirestoreMission? {
        missionViewModel.missions.first { $0.id == missionId }
    }
    
    enum AlertType: Identifiable {
        case alreadyVerified
        case beforeStart
        // 다른 유형...
        
        var id: Int {
            hashValue
        }
    }
    
    // 알림 상태 변수들
    @State private var showCamera = false // 카메라 촬영뷰
    @State private var image: UIImage?
    @State private var showConfirmButton = false
    @State private var showConfirmation = false // 촬영된 사진 인증 뷰
    @State private var showMidnightButton = false // 수면미션 환급 버튼
    @State private var captureTime: Date?
    @State private var showVerificationCompleted2 = false
    @State private var showButton = true // 인증완료 버튼 표시여부
    
    init(mission: FirestoreMission, selectedMissionId: Binding<UUID?>) {
        self.missionId = mission.id
        self._selectedMissionId = selectedMissionId
    }
    
    let deviceActivityCenter = DeviceActivityCenter()
    
    var formattedAmount: String {
        guard let mission = mission else {
            return ""
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: mission.actualAmount)) ?? ""
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                Text("예치금: \(formattedAmount)원")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(.red)
                    .opacity(0.8)
                
                HStack {
                    Text("●")
                        .foregroundColor(Color.green)
                        .font(.system(size: 10))
                        .cornerRadius(10)
                    
                    Text("\(mission?.currentStore ?? "")")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
                
                
                if let mission = mission {
                    VStack(spacing: 10) {
                        Image(systemName: mission.imageName)
                            .symbolRenderingMode(.palette)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.blue, .green)
                            .font(.system(size: 100, weight: .light))
                            .opacity(0.9)
                        
                        Text(mission.missionType)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
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
                                if mission?.missionStatus == .beforeStart || mission?.missionStatus == .inProgress || mission?.missionStatus == .verificationCompleted1 {
                                    GreenButton(title: "사진인증") {
                                        if mission?.missionStatus == .verificationCompleted1 {
                                            alertType = .alreadyVerified
                                        } else if mission?.missionStatus == .inProgress {
                                            self.showCamera = true
                                        } else if mission?.missionStatus == .beforeStart {
                                            alertType = .beforeStart
                                        }
                                    }
                                    .alert(item: $alertType) { alertType in
                                        switch alertType {
                                        case .alreadyVerified:
                                            return Alert(title: Text("알림"), message: Text("이미 사진인증을 완료하셨습니다.\n\n시간이 다 되면 차단된 앱을 클릭하여 \n'미션완료' 버튼을 누르세요."), dismissButton: .default(Text("확인")))
                                        case .beforeStart:
                                            return Alert(title: Text("알림"), message: Text("미션이 시작되어야 인증이 가능합니다."), dismissButton: .default(Text("확인")))
                                            // 다른 알림 유형 처리
                                        }
                                        
                                    }
                                    .fullScreenCover(isPresented: $showCamera) {
                                        ImagePicker(image: self.$image) { selectedImage, captureTime in
                                            self.image = selectedImage
                                            self.captureTime = captureTime
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
                                                
                                                GreenButton(title: "인 증") {
                                                    // Get an instance of the mission from your data model
                                                    guard let mission = self.mission else {
                                                        print("Mission not found")
                                                        return
                                                    }
                                                    
                                                    // Make sure there is an image to upload
                                                    guard let img = self.image else {
                                                        print("No image to upload")
                                                        return
                                                    }
                                                    
                                                    // Make sure the capture time is available
                                                    guard let captureTime = self.captureTime else {
                                                        print("Capture time not available")
                                                        return
                                                    }
                                                    
                                                    // Upload the image and metadata
                                                    missionViewModel.uploadImage(img, for: mission, captureTime: captureTime)
                                             
                                                    self.showConfirmation = false
                                                    self.selectedMissionId = nil
                                                    missionViewModel.toVerification1(missionId: self.missionId)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.black)
                                    }
                                }
                            }
                        }
                    }
                    if mission?.missionType == "수면", mission?.missionStatus == .verificationCompleted2 {
                        BlueButton(title: "인증완료") {
                                showVerificationCompleted2 = true
                            }
                            .alert(isPresented: $showVerificationCompleted2) {
                                Alert(title: Text("알림"), message: Text("모든 인증을 완료하셨습니다.\n오늘 자정에 환급 버튼이 생성됩니다."),
                                      dismissButton: .default(Text("확인")))
                            }
                        }
                    
                    
                    if mission?.missionType == "수면", mission?.missionStatus != .verificationCompleted1, mission?.missionStatus != .verificationCompleted2 {
                        Text("남은 시간이 1시간 이하일 때\n인증 버튼이 활성화됩니다.")
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                    }
                    if mission?.missionType == "수면", (mission?.missionStatus == .verificationCompleted1 || mission?.missionStatus == .verificationCompleted2) {
                        Text("인증사진이 관리자에게 승인되면,\n오늘 자정에 환급 버튼이 활성화됩니다.")
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                    }
                }
                // 자정 이후에 생기는 환급 버튼
                if showMidnightButton {
                    GreenButton(title: "환 급") {
                        refundMissionAmount()
                        missionViewModel.completeMission(missionId: missionId)
                    }
                }
                //미션 상태가 인증완료 일때만 포기 버튼이 사라짐
                if mission?.missionStatus != .verificationCompleted2 {
                    
                    BlueButton(title: "포 기") {
                        showAlert2 = true
                    }
                    .alert(isPresented: $showAlert2) {
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
                if mission?.missionStatus == .verificationCompleted2 && mission?.missionType == "집중" {
                    GreenButton(title: "환 급") {
                        refundMissionAmount()
                        missionViewModel.completeMission(missionId: missionId)
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
        .padding(.top, 30)
        .onAppear {
            midnightBackMoney() //자정에 환급버튼 생성 함수
        }
    }
    
    // 토요일 오후 06:38 ~ 토요일 오후 07:38 표현해주는 함수임
    func formatMissionTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE a hh:mm"
        let startTimeString = formatter.string(from: mission?.selectedTime1 ?? Date())
        let endTimeString = formatter.string(from: mission?.selectedTime2 ?? Date())
        return "\(startTimeString) ~ \(endTimeString)"
    }
    // 남은 시간이 0초가 되면 자동으로 미션상태가 실패로 되고 앱차단이 풀림
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
                    if mission?.missionType == "수면" && mission?.missionStatus == .inProgress {
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
    //오늘밤 자정이 되면 수면미션 환급 버튼 생성해주는 함수
    func midnightBackMoney() {
        guard let missionEndTime = mission?.selectedTime2,
              mission?.missionType == "수면",
              mission?.missionStatus == .verificationCompleted2 else {
            return
        }
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: missionEndTime)!
        let midnight = calendar.startOfDay(for: nextDay)
        
        let now = Date()
        if now >= midnight {
            print("It's past midnight of the next day!")
            // 현재 시간이 selectedTime2의 다음날 자정 이후일 때 실행하려는 코드를 여기에 작성
            showMidnightButton = true
        }
    }
    // 환급 버튼 누를 시 예치금이 남은 잔고에 더해주는 함수
    func refundMissionAmount() {
        guard let mission = mission else { return }

        let refundAmount = mission.actualAmount
        var finalBalance = userInfoViewModel.balance + refundAmount

        userInfoViewModel.updateBalance(newBalance: finalBalance) { error in
            if let error = error {
                print("Failed to refund balance: \(error)")
            } else {
                userInfoViewModel.balance = finalBalance // ViewModel의 잔액 업데이트
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
