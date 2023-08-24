

import SwiftUI

struct PasswordResetView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var email: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showSuccessAlert: Bool = false // 성공 알림 상태 추가
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("이메일", text: $email)
                .autocapitalization(.none)
                .padding()
                .border(Color.gray, width: 0.5)
            Button(action: {
                loginViewModel.sendPasswordResetWithEmail(email) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showAlert = true
                    } else {
                        self.showSuccessAlert = true // 성공 시 성공 알림 상태 업데이트
                    }
                }
            }) {
                Text("비밀번호 재설정 이메일 보내기")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK"), action: {
                self.showAlert = false
            }))
        })
        .alert(isPresented: $showSuccessAlert, content: { // 성공 알림 추가
            Alert(title: Text("성공"), message: Text("이메일이 전송되었습니다."), dismissButton: .default(Text("OK"), action: {
                self.showSuccessAlert = false
            }))
        })
    }
}


struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
