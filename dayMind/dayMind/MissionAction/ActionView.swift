
//import SwiftUI
//import ManagedSettings
//
//struct MissionAction: View {
//    @State var storeName: String = ""
//       var body: some View {
//           Button("앱 잠금 시작") {
//               let store = ManagedSettingsStore(named: ManagedSettingsStore.Name(storeName))
//               let applicationSettings = ApplicationSettings()
//               applicationSettings.blockedApplications = store.fetch()  // Fetch the selected apps from store
//               ManagedSettingsUI.apply(applicationSettings)
//           }
//       }
//   }
//struct MissionAction_Previews: PreviewProvider {
//    static var previews: some View {
//        MissionAction()
//    }
//}
