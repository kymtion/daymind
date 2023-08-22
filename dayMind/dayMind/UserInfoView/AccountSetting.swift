
import SwiftUI

struct AccountSetting: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingLogoutAlert = false
    
    var body: some View {
      
            VStack(spacing: 30) {
                NavigationLink {
                    UserProfileUpdateView()
                } label: {
                    HStack {
                        Text("이름(닉네임) 변경")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                NavigationLink {
                    ChangePasswordView()
                } label: {
                    HStack {
                        Text("비밀번호 재설정")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                NavigationLink {
                    DeleteAccountView()
                } label: {
                    HStack {
                        Text("회원 탈퇴")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                Button {
                    showingLogoutAlert = true
                } label: {
                    HStack {
                        Text("로그아웃")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(title: Text("로그아웃"),
                          message: Text("로그아웃 하시겠습니까?"),
                          primaryButton: .default(Text("확인")) {
                        userInfoViewModel.logout()
                    },
                          secondaryButton: .cancel(Text("취소")))
                }
                
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .padding()
        }
    }

struct AccountSetting_Previews: PreviewProvider {
    static var previews: some View {
        AccountSetting().environmentObject(UserInfoViewModel())
    }
}
