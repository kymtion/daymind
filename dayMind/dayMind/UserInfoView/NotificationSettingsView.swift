
import SwiftUI

struct NotificationSettingsView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    
    var body: some View {
            List {
                Toggle("미션 시작 알림", isOn: $missionViewModel.startNotificationEnabled)
                Toggle("집중 미션 종료 알림", isOn: $missionViewModel.endNotificationEnabled)
                Toggle("수면 미션 종료 10분 전 알림", isOn: $missionViewModel.before10MinNotificationEnabled)
                Toggle("미션 등록 격려 메시지", isOn: $missionViewModel.firebasePushNotificationEnabled)
            }
            .navigationTitle("알림 설정")
        }
    }

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
            .environmentObject(MissionViewModel())
    }
}
