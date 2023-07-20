
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @EnvironmentObject var missionViewModel: MissionViewModel
    @Environment(\.scenePhase) var scenePhase
    
    let layout: [GridItem] = [
        GridItem(.flexible()),
    ]
    
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
                ScrollView {
                    LazyVGrid(columns: layout, spacing: 10) {
                        ForEach(missionViewModel.missions.filter { mission in
                            let missionStatus = missionViewModel.missionStatusManager.status(for: mission.id) ?? .beforeStart
                            return missionStatus == .beforeStart || missionStatus == .inProgress || missionStatus == .verificationCompleted
                        }.sorted(by: { $0.selectedTime1 < $1.selectedTime1 }), id: \.id) { mission in
                            NavigationLink {
                                ActionView(mission: mission)
                            } label: {
                                HomeCell(mission: mission)
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .shadow(color: Color.gray.opacity(0.15), radius: 3, x: 0, y: 0)
                            }
                        }

                    }
                }
                .onAppear {
                    missionViewModel.updateMissionStatuses()
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                missionViewModel.updateMissionStatuses()
            }
        }
    }
}

struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(MissionViewModel())
            .environmentObject(UserInfoViewModel())
    }
}
