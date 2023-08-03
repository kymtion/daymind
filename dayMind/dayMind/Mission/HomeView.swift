
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
                        let filteredMissions = missionViewModel.missions.filter { mission in
                            return mission.missionStatus == .beforeStart || mission.missionStatus == .inProgress || mission.missionStatus == .verificationCompleted
                        }.sorted(by: { $0.selectedTime1 < $1.selectedTime1 })
                        
                        if filteredMissions.isEmpty {
                            Text("현재 등록된 미션이 없습니다.")
                                .opacity(0.7)
                                .padding(.top)
                        } else {
                            ForEach(filteredMissions, id: \.id) { mission in
                                NavigationLink {
                                    ActionView(mission: mission)
                                } label: {
                                    HomeCell(firestoreMission: mission)
                                        .frame(width: UIScreen.main.bounds.width * 0.9)
                                        .shadow(color: Color.gray.opacity(0.15), radius: 3, x: 0, y: 0)
                                }
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
