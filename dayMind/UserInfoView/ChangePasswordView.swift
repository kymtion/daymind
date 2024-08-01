import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var currentPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Text("카카오 로그인 사용자는\n비밀번호 변경이 불가능합니다.")
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .opacity(0.5)
                .padding()
            
            SecureField("현재 비밀번호", text: $currentPassword)
                .padding()
                .border(Color.gray, width: 0.5)
            SecureField("새 비밀번호", text: $newPassword)
                .padding()
                .border(Color.gray, width: 0.5)
            SecureField("비밀번호 확인", text: $confirmPassword)
                .padding()
                .border(Color.gray, width: 0.5)
            Button(action: {
                if currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
                        alertMessage = "비밀번호를 입력해주세요." // 알림 메시지
                        showingAlert = true
                    } else if newPassword != confirmPassword {
                        alertMessage = "비밀번호가 일치하지 않습니다."
                        showingAlert = true
                    } else {
                        userInfoViewModel.reauthenticate(currentPassword: currentPassword) { error in
                            if error != nil {
                                alertMessage = "알 수 없는 오류가 발생했습니다. 다시 시도해주세요."
                                showingAlert = true
                            } else {
                                userInfoViewModel.updatePassword(to: newPassword) { error in
                                    if let error = error {
                                        alertMessage = "비밀번호 변경에 실패했습니다." // 적절한 메시지로 변경
                                    } else {
                                        alertMessage = "비밀번호가 성공적으로 변경되었습니다."
                                    }
                                    showingAlert = true
                                }
                            }
                        }
                    }
            }) {
                Text("비밀번호 변경")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }
}


struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(UserInfoViewModel())
    }
}
