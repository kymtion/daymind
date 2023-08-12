import SwiftUI

struct MissionListView: View {
    
    @StateObject var vm = MissionViewModel()
    
    
    let layout: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
            ZStack {
                Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 25) {
                        HStack{
                            Text("🎯 미션 리스트")
                                .font(.system(size: 30, weight: .medium))
                            Spacer()
                        }
                        LazyVGrid(columns: layout) {
                            ForEach(missionData) { mission in
                                Button {
                                    vm.selectedMission = mission
                                    vm.showDetailView = true
                                } label: {
                                    MissionRow(mission: mission)
                                        .shadow(color: Color.gray.opacity(0.15), radius: 3, x: 0, y: 0)
                                }
                                .fullScreenCover(isPresented: $vm.showDetailView) {
                                    DetailView()
                                        .environmentObject(vm)
                                }
                            }
                        }
                    }
                    .padding(25)
                }
            }
        }
    }
    
    
    struct missionTableView_Previews: PreviewProvider {
        static var previews: some View {
            MissionListView()
        }
    }
