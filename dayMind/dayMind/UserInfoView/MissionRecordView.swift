
import SwiftUI

struct MissionRecordView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    
    var body: some View {
        List {
            ForEach(userInfoViewModel.getGroupedMissions().keys.sorted(by: >), id: \.self) { key in
                if let missions = userInfoViewModel.getGroupedMissions()[key] {
                    Section(header: Text(key)
                        .font(.system(size: 17, weight: .semibold))
                    ) {
                        ForEach(missions) { mission in
                            RecordCell(mission: mission)
                                .environmentObject(userInfoViewModel)
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                .listRowSeparator(.hidden)
                                .frame(height: 120)
                        }
                    }
                }
            }
        }
        .onAppear {
            userInfoViewModel.loadMissionStatusManager()
        }
    }
}

struct MissionRecordView_Previews: PreviewProvider {
    static var previews: some View {
        MissionRecordView()
            .environmentObject(UserInfoViewModel())
    }
}
