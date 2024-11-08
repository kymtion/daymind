
import SwiftUI

struct RecordCell: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    
    var firestoreMission: FirestoreMission
    
    var missionTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a hh:mm"
        return "\(dateFormatter.string(from: firestoreMission.selectedTime1)) ~ \(dateFormatter.string(from: firestoreMission.selectedTime2))"
    }
    
    var missionDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM.dd (E)"
        return dateFormatter.string(from: firestoreMission.selectedTime2)
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
                }
                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.27)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(missionTime)
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.trailing)
                    HStack {
                        let missionStatus = firestoreMission.missionStatus
                        Text(missionStatus.rawValue)
                            .font(.system(size: 10))
                            .foregroundColor(missionStatus.color)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(missionStatus.color, lineWidth: 1))
                        Text(missionDate)
                            .font(.system(size: 14, weight: .semibold))
                            .opacity(0.8)
                    }
                    
                    HStack {
                        Text("예치금: \(formattedAmount)원")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red)
                            .opacity(0.8)
                    }
                }
                
                .padding(.vertical, 20)
                
            }
//            .background(Color.white)
        }
    }

//struct RecordCell_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordCell(firestoreMission: FirestoreMission(id: UUID(), selectedTime1: Date(), selectedTime2: Date(), currentStore: "", missionType: "집중", imageName: "lock.iphone", missionStatus: .beforeStart))
//                 .environmentObject(UserInfoViewModel())
//        
//    }
//}
