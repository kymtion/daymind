import SwiftUI

struct UserInfoView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var showingReauthentication = false
    @State private var navigateToAccountSettings = false
    
    var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("UID: \(userInfoViewModel.uid)")
                    Text("이메일: \(userInfoViewModel.email)")
                    Text("이름(닉네임): \(userInfoViewModel.displayName)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 10)
                    .foregroundColor(.gray.opacity(0.1))
                
                VStack(alignment: .leading, spacing: 20) {
                    NavigationLink {
                        AccountSetting().environmentObject(userInfoViewModel)
                    }label: {
                        HStack {
                            Text("계정 설정")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }
                }
                .padding()
            }
        }
    }
  
struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoView()
            .environmentObject(UserInfoViewModel())
    }
}
