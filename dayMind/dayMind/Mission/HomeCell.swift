
import SwiftUI

struct HomeCell: View {
    @EnvironmentObject var missionViewModel: MissionViewModel
    
    var mission: MissionStorage
    
    var missionTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh:mm"
        return "\(dateFormatter.string(from: mission.selectedTime1)) ~ \(dateFormatter.string(from: mission.selectedTime2))"
    }
    
    var body: some View {
       
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
                
                VStack(alignment: .leading, spacing: 10) {
                    
                   
                    
                    Text(missionTime)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.black)
                   
                    HStack {
                        Text(mission.status.description)
                                .font(.system(size: 10))
                                .foregroundColor(mission.status.color)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(mission.status.color, lineWidth: 1))
                        Spacer()
                        
                    }
                    .padding(.trailing, 22)
                    
                    
                    HStack {
                        Text("예치금: 5,000원")
                            .font(.system(size: 17, weight: .semibold))
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
  

        }
    }


struct homeCell_Previews: PreviewProvider {
    static var previews: some View {
        HomeCell(mission: MissionStorage(selectedTime1: Date(), selectedTime2: Date(), currentStore: "", missionType: "집중", imageName: "lock.iphone"))
                   .environmentObject(MissionViewModel())
    }
}
