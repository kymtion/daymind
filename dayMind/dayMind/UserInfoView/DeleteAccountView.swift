import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var showConfirmationAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Text("계정 삭제")
                .font(.system(size: 30, weight: .medium))
            
            if userInfoViewModel.email.isEmpty { // 카카오 로그인 사용자의 경우
                Text("카카오 로그인 사용자는 비밀번호 입력 없이 계정을 삭제할 수 있습니다.")
                    .opacity(0.5)
                    .padding()
                    .multilineTextAlignment(.center)
            } else { // 파이어베이스로 계정을 만든 사용자의 경우
                SecureField("비밀번호를 입력하세요.", text: $password)
                    .padding()
                    .border(Color.gray, width: 0.5)
            }
            
            Button {
                if userInfoViewModel.email.isEmpty {
                    showConfirmationAlert = true
                } else {
                    userInfoViewModel.reauthenticate(currentPassword: password) { error in
                        if let error = error {
                            errorMessage = "비밀번호가 잘못되었습니다."
                            showErrorAlert = true
                        } else {
                            showConfirmationAlert = true
                        }
                    }
                }
            } label: {
                Text("계정 삭제")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(10)
            }
            .disabled(userInfoViewModel.email.isEmpty ? false : password.isEmpty)
            
            if showConfirmationAlert {
                
                Text("정말 계정을 삭제하시겠습니까?")
                    .font(.system(size: 15,weight: .bold))
                Text("계정에 남아있는 보유 잔액은 전부 소멸됩니다.")
                    .font(.system(size: 13,weight: .regular))
                    .opacity(0.7)
                Button(action: {
                    
                    // 파이어베이스 계정 삭제
                    userInfoViewModel.deleteUser { error in
                        if let error = error {
                            errorMessage = "계정을 삭제하는 중 오류가 발생했습니다. 계정 삭제를 위해서는 최근 로그인이 필요하니 다시 로그인해주세요."
                            showErrorAlert = true
                        } else {
                            errorMessage = "계정이 성공적으로 삭제되었습니다."
                            showErrorAlert = true
                        }
                    }
                }) {
                    Text("네, 삭제하겠습니다.")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text(errorMessage))
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView().environmentObject(UserInfoViewModel())
    }
}
