import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {

    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var email = ""
    @State private var password = ""
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("이메일", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                SecureField("비밀번호", text: $password)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                Button {
                    loginViewModel.email = email
                    loginViewModel.password = password
                    loginViewModel.loginWithEmail()
                } label: {
                    Text("로그인")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5)
                }
                
                .padding()
                .alert(isPresented: Binding<Bool>(
                    get: { self.loginViewModel.error != nil },
                    set: { _ in self.loginViewModel.error = nil }
                ), content: { () -> Alert in
                    Alert(title: Text("로그인 실패"), message: Text(self.loginViewModel.error?.localizedDescription ?? "Unknown"), dismissButton: .default(Text("확인")))
                })
                
                //카카오톡 금 오후 1시29분
                Button(action: {
                    loginViewModel.loginWithKakao()
                       }) {
                           Text("Log in with Kakao")
                               .foregroundColor(.white)
                               .padding()
                               .background(Color.yellow)
                               .cornerRadius(5)
                       }
                //카카오톡
                
                NavigationLink (destination: SignUpView()) {
                    Text("회원가입")
                }
                .padding()
                .border(Color.gray, width: 0.5)
                
                NavigationLink(destination: PasswordResetView()) {
                    Text("비밀번호 찾기")
                }
                .padding()
                .border(Color.gray, width: 0.5)
            }
            .padding()
            
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(LoginViewModel())
    }
}
