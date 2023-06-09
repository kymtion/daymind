
import SwiftUI

struct HomeCell: View {
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Image(systemName: "moon.zzz")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.yellow)
                    .font(.system(size: 24))
                    .frame(width: 50, height: 50)
                
                Text("수면")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(25)
            .background(Color.white)
            .frame(width: 125, height: 125)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.2)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Text("오전 10:00 ~ 오후 8:00")
                    .font(.system(size: 17, weight: .bold))
                Text("인증시간: 오전 9:30 ~ 10:00")
                    .font(.system(size: 12))
                HStack(spacing: 70) {
                    Text("예치금: 5,000원")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.red)
                        .opacity(0.8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                }
            }
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(10)
        .padding(.leading)
   
        
        .padding(.horizontal, 0)
    }
}
struct homeCell_Previews: PreviewProvider {
    static var previews: some View {
        HomeCell()
    }
}
