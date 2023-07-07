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
                    VStack {
                        Text("🎯 미션 리스트")
                            .font(.system(size: 30, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        LazyVGrid(columns: layout) {
                            ForEach(missionData) { mission in
                                NavigationLink {
                                    DetailView(mission: mission)
                                } label: {
                                    MissionRow(mission: mission)
                                        .shadow(color: Color.gray.opacity(0.15), radius: 3, x: 0, y: 0)
                                    
                                }
                            }
                        }
                    }
                    .padding([.top, .leading, .trailing], 25)
                    
                }
            }
            
        }
    }
}

struct missionTableView_Previews: PreviewProvider {
    static var previews: some View {
        MissionListView()
    }
}
