
import SwiftUI

struct TapBarView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("홈")
                }
            
            MissionListView()
                .tabItem {
                    Image(systemName: "rectangle.grid.2x2")
                    Text("미션 리스트")
                }
        }
    }
}

struct TapBarView_Previews: PreviewProvider {
    static var previews: some View {
        TapBarView()
    }
}
