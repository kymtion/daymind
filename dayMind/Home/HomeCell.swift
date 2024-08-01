
import SwiftUI

struct HomeCell: View {
    @EnvironmentObject var missionViewModel: MissionViewModel
    
    var firestoreMission: FirestoreMission
    
    var missionTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a hh:mm"
        return "\(dateFormatter.string(from: firestoreMission.selectedTime1)) ~ \(dateFormatter.string(from: firestoreMission.selectedTime2))"
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: firestoreMission.actualAmount)) ?? ""
    }
    
    var body: some View {
       
            HStack {
                VStack(spacing: 5) {
                    Image(systemName: firestoreMission.imageName)
                        .symbolRenderingMode(.palette)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.blue, .green)
                        .font(.system(size: 50, weight: .light))
                    
                    Text(firestoreMission.missionType)
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
                        Text(firestoreMission.missionStatus.rawValue)
                                .font(.system(size: 10))
                                .foregroundColor(firestoreMission.missionStatus.color)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(firestoreMission.missionStatus.color, lineWidth: 1))
                        Spacer()
                        
                    }
                    .padding(.trailing, 22)
                    
                    
                    HStack {
                        Text("예치금: \(formattedAmount)원")
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


//struct homeCell_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeCell(firestoreMission: FirestoreMission(id: UUID(), selectedTime1: Date(), selectedTime2: Date(), currentStore: "", missionType: "집중", imageName: "lock.iphone", missionStatus: .beforeStart))  // 이 부분을 수정해주었습니다.
//            .environmentObject(MissionViewModel())
//    }
//}
