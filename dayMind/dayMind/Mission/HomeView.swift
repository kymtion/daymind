
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @EnvironmentObject var missionViewModel: MissionViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarTitle("오늘의 미션")
                    .navigationBarItems(trailing: NavigationLink(destination: UserInfoView().environmentObject(userInfoViewModel)) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.black)
                            .opacity(0.7)
                            .frame(width: 30, height: 30)
                    }
                    )
                VStack {
                    List {
                        ForEach(missionViewModel.missions, id: \.id) { mission in
                            NavigationLink {
                                ActionView(mission: mission)
                            }label: {
                                Text("store: mission.currentStore")
//                                HomeCell()
                               
                            }
                        }
                    }
                }
            }
        }
    }
}
struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(UserInfoViewModel())
    }
}
