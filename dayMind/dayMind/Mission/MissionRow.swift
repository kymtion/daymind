
import SwiftUI

struct MissionRow: View {
    
    var mission: Mission
    
    var body: some View {
            VStack(spacing: 20) {
                Image(systemName: mission.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(mission.color)
                    .frame(width: UIScreen.main.bounds.width * 0.16)

                
                Text(mission.name)
                    .font(.system(size: 22))
                    .foregroundColor(Color.black)
                
            }
            .frame(width: UIScreen.main.bounds.width * 0.30, height: UIScreen.main.bounds.width * 0.30)
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
        
    }
        
    }


struct MissionListCell_Previews: PreviewProvider {
    static var previews: some View {
        MissionRow(mission: missionData[0])
    }
}
