
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.white
            
            VStack {
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.3)
                
                ProgressView("Loading...")
                
                
            }
            
                        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
struct LodingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
