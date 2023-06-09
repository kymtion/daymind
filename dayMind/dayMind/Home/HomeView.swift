
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    
    var body: some View {
        
        NavigationView {
            Text("현재 등록된 미션이 없습니다.")
                .navigationBarTitle("오늘의 미션")
                .navigationBarItems(trailing: NavigationLink(destination: UserInfoView().environmentObject(userInfoViewModel)) {
                    Image(systemName: "person")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.black)
                        .opacity(0.7)
                        .frame(width: 30, height: 30)
                }
                )
        }
    }
}
struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(LoginViewModel())
    }
}
