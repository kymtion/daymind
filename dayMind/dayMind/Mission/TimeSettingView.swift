
import SwiftUI
import ManagedSettings
import FamilyControls
import DeviceActivity

struct TimeSettingView: View {
    
    @ObservedObject var vm: MissionViewModel
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
                        Text("현재 앱 허용 리스트: \(vm.currentStore)")
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
                        AllowListView(isPopupPresented: $isPopupPresented, vm: vm)
                    }
                    Spacer()
                    Button {
                        let currentStoreName = ManagedSettingsStore.Name(rawValue: vm.currentStore)
                        if let store = vm.managedSettings[currentStoreName] {
                            // 이미 선택된 앱, 카테고리, 웹 도메인 토큰 가져오기
                            let selectedAppTokens = store.applicationTokens
                            let selectedWebDomainTokens = store.webDomainTokens
                            
                            let selectedList = ManagedSettingsStore(named: currentStoreName)
                            // 선택된 앱들을 차단에서 제외하고 나머지 모든 앱을 차단
                            selectedList.shield.applicationCategories = .all(except: selectedAppTokens)
                            selectedList.shield.webDomainCategories = .all(except: selectedWebDomainTokens)
                            
                            
                            
                        }
                    } label: {
                        Text("앱 차단 시작!")
                            .padding(10)
                            .font(.system(size: 25, weight: .bold))
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .background(Color(red: 242 / 255, green: 206 / 255, blue: 102 / 255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        let currentStoreName = ManagedSettingsStore.Name(rawValue: vm.currentStore)
                        let selectedList = ManagedSettingsStore(named: currentStoreName)
                        selectedList.clearAllSettings()
                        
                    } label: {
                        Text("앱 차단 종료!")
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
        TimeSettingView(vm: MissionViewModel(), mission: missionData[0])
    }
}
