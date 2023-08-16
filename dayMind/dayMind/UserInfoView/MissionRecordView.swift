
import SwiftUI

struct MissionRecordView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    
    var body: some View {
        
        let (successAmount, failureAmount) = userInfoViewModel.calculateAmounts()
        
        VStack(spacing: 10) {
            HStack {
                Text("총 환급 금액")
                    .font(.system(size: 17, weight: .medium))
                    .opacity(0.7)
                Spacer()
                Text("\(successAmount.formattedWithComma())원")
                    .font(.system(size: 20, weight: .medium))
            }
            Divider()
            HStack {
                Text("벌금 총액")
                    .font(.system(size: 17, weight: .medium))
                    .opacity(0.7)
                Spacer()
                Text("\(failureAmount.formattedWithComma())원")
                    .font(.system(size: 20, weight: .medium))
            }
            
        }
        
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        
            List {
                ForEach(userInfoViewModel.getGroupedMissions().keys.sorted(by: >), id: \.self) { key in
                    if let missions = userInfoViewModel.getGroupedMissions()[key] {
                        Section(header: Text(key)
                            .font(.system(size: 17, weight: .semibold))
                        ) {
                            ForEach(missions) { mission in
                                RecordCell(firestoreMission: mission)
                                    .environmentObject(userInfoViewModel)
                                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                    .listRowSeparator(.hidden)
                                    .frame(height: 120)
                            }
                        }
                    }
                }
            }
        }
    }



struct MissionRecordView_Previews: PreviewProvider {
    static var previews: some View {
        MissionRecordView()
            .environmentObject(UserInfoViewModel())
    }
}
