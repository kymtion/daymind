import SwiftUI

struct MissionListView: View {
    
    @StateObject var vm = MissionViewModel()
    
    
    let layout: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    LazyVGrid(columns: layout) {
                        ForEach(missionData) { mission in
                            NavigationLink {
                                DetailView(vm: vm, mission: mission)
                            } label: {
                                MissionRow(mission: mission)
                                
                            }
                        }
                    }
                }
                .padding([.top, .leading, .trailing], 15)
                
            }
            .navigationTitle("🎯 미션 리스트")
       
            
        }
    }
}

struct missionTableView_Previews: PreviewProvider {
    static var previews: some View {
        MissionListView()
    }
}
