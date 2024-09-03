import SwiftUI
import WebKit

struct LegalNoticeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Link(destination: URL(string: "https://daymind.co.kr")!) {
                HStack {
                    Text("개인정보 처리방침")
                        .font(.system(size: 20, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .opacity(0.7)
                }
            }
            
            Link(destination: URL(string: "https://daymind.co.kr")!) {
                HStack {
                    Text("서비스 이용약관")
                        .font(.system(size: 20, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .opacity(0.7)
                }
            }
        }
        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        .padding()
    }
}



#Preview {
    LegalNoticeView()
}
