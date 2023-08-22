
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("Loading...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.8)) // 반투명 배경
            .ignoresSafeArea()
    }
}



struct LodingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
