import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showErrorAlert = false
    
    
    var body: some View {
        ZStack {
            
            NavigationView {
                VStack(spacing: 15) {
                    TextField("이메일", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .border(Color.gray, width: 0.5)
                    
                    SecureField("비밀번호", text: $password)
                        .padding()
                        .border(Color.gray, width: 0.5)
                    VStack {
                        Button {
                            loginViewModel.email = email
                            loginViewModel.password = password
                            loginViewModel.loginWithEmail { error in
                                if error != nil {
                                    showErrorAlert = true
                                }
                            }
                        } label: {
                            Text("로그인")
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.vertical, 13)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(10)
                            
                        }
                        .alert(isPresented: $showErrorAlert) {
                            Alert(title: Text("로그인 실패"), message: Text(loginViewModel.error?.localizedDescription ?? "Unknown"), dismissButton: .default(Text("확인")))
                        }
                        
                        //카카오톡 금 오후 1시29분
                        Button{
                            loginViewModel.loginWithKakao { error in
                                if error != nil {
                                    showErrorAlert = true
                                }
                            }
                            
                        } label: {
                            Image("kakao")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                            
                        }
                    }
                    
                    HStack(spacing: 10) {
                        NavigationLink (destination: SignUpView()) {
                            Text("회원가입")
                                .foregroundColor(.green.opacity(0.8))
                                .font(.system(size: 15, weight: .medium))
                        }
                        
                        Rectangle() // 수직 선
                            .fill(Color.green.opacity(0.5)) // 선의 색상을 녹색으로 설정
                            .frame(width: 1.5, height: 15) // 선의 두께와 길이를 설정
                        
                        NavigationLink(destination: PasswordResetView()) {
                            Text("비밀번호 찾기")
                                .foregroundColor(.green.opacity(0.8))
                                .font(.system(size: 15, weight: .medium))
                                
                        }
                    }
                    
                }
                .padding()
            }
            if loginViewModel.isLoading {
                LoadingView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(LoginViewModel())
    }
}
