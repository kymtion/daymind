
import SwiftUI

struct HomeCell: View {
    @EnvironmentObject var missionViewModel: MissionViewModel
    
    var missionType: String
    
    var mission: Mission? {
        missionData.first(where: { $0.missionType == missionType })
    }
    
    var missionTime: String {
        guard let missionStorage = missionViewModel.missionStorage(forType: missionType) else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return "\(dateFormatter.string(from: missionStorage.selectedTime1)) ~ \(dateFormatter.string(from: missionStorage.selectedTime2))"
    }
    
    var body: some View {
        if let mission = mission {
            HStack {
                VStack {
                    Image(systemName: mission.imageName)
                        .symbolRenderingMode(.palette)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.blue, .green)
                        .font(.system(size: 999, weight: .light))
                        .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.width * 0.12)
                    
                    Text(mission.missionType)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                }
                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.27)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(missionTime)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color.black)
                    Text("인증시간: 오전 9:30 ~ 10:00")
                        .font(.system(size: 12))
                        .foregroundColor(Color.black)
                    
                    HStack {
                        Text("예치금: 5,000원")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.red)
                            .opacity(0.8)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(Color.black)
                    }
                    .padding(.trailing, 22)
                }
                .padding(.vertical, 20)
            }
            .background(Color.white)
            .cornerRadius(10)
            .frame(width: UIScreen.main.bounds.width * 0.9)
        } else {
            EmptyView()
        }
    }
}

struct homeCell_Previews: PreviewProvider {
    static var previews: some View {
        HomeCell(missionType: "집중")
            .environmentObject(MissionViewModel())
    }
}
