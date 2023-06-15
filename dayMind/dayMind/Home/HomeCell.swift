
import SwiftUI

struct HomeCell: View {
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Image(systemName: "moon.zzz")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color(red: 228 / 255, green: 175 / 255, blue: 9 / 255))
                    .font(.system(size: 24))
                    .frame(width: UIScreen.main.bounds.width * 0.2)
                
                Text("수면")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
            }
            .padding(10)
            .background(Color.white)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)

            .frame(width: UIScreen.main.bounds.width * 0.3)
            .clipShape(RoundedRectangle(cornerRadius: 10))
           
            
            VStack(alignment: .leading, spacing: 20) {
                Text("오전 10:00 ~ 오후 8:00")
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
                .padding(.trailing)
            }
        }
        .background(Color.white)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .cornerRadius(10)
        .padding()

    }
}
struct homeCell_Previews: PreviewProvider {
    static var previews: some View {
        HomeCell()
    }
}
