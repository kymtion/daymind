
import SwiftUI

struct MissionRow: View {
    
    var mission: Mission
    
    var body: some View {
            VStack(spacing: 10) {
                Image(systemName: mission.imageName)
                    .symbolRenderingMode(.palette)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.blue, .green)
                    .font(.system(size: 65, weight: .light))
                    .opacity(0.9)

                
                Text(mission.missionType)
                    .font(.system(size: 20))
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
        MissionRow(mission: missionData[1])
    }
}
