import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var confirmPassword = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            Text("회원가입")
                .font(.largeTitle)
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
            Button(action: {
                // 비밀번호와 확인 필드의 값이 일치하는지 확인
                guard loginViewModel.password == confirmPassword else {
                    errorMessage = "비밀번호가 일치하지 않습니다."
                    return
                }
                
                // 신규 사용자 가입 처리
                loginViewModel.signUpSubject.send(())
            }) {
                Text("가입하기")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(5)
            }
            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
            }
        }
        .padding()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView().environmentObject(LoginViewModel())
    }
}
