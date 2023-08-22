import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func signUp() {
        guard isValidEmail(loginViewModel.email) else {
            alertMessage = "올바른 이메일 주소를 입력해주세요."
            showAlert = true
            return
        }
        
        guard loginViewModel.password.count >= 8 else {
            alertMessage = "비밀번호는 최소 8자 이상이어야 합니다."
            showAlert = true
            return
        }
        
        guard loginViewModel.password == confirmPassword else {
            alertMessage = "비밀번호가 일치하지 않습니다."
            showAlert = true
            return
        }
        
        guard !loginViewModel.displayName.isEmpty else {
            alertMessage = "이름을 입력해주세요."
            showAlert = true
            return
        }
        
        // 모든 검사를 통과하면 회원가입 프로세스 진행
        loginViewModel.signUpWithEmail { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    var body: some View {
        ZStack {
            VStack {
                Text("회원가입")
                    .font(.system(size: 30, weight: .medium))
                TextField("이메일", text: $loginViewModel.email)
                    .autocapitalization(.none)
                    .padding()
                    .border(Color.gray, width: 0.5)
                SecureField("비밀번호", text: $loginViewModel.password)
                    .padding()
                    .border(Color.gray, width: 0.5)
                SecureField("비밀번호 확인", text: $confirmPassword)
                    .padding()
                    .border(Color.gray, width: 0.5)
                TextField("이름(닉네임)", text: $loginViewModel.displayName)
                    .autocapitalization(.none)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Button {
                    signUp()
                } label: {
                    Text("가입하기")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
            if loginViewModel.isLoading {
                LoadingView() // 로딩 뷰 표시
            }
        }
    }
}
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView().environmentObject(LoginViewModel())
    }
}
