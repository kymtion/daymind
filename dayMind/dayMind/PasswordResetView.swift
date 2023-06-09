

import SwiftUI

struct PasswordResetView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var email: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            TextField("이메일", text: $email)
                .autocapitalization(.none)
                .padding()
                .border(Color.gray, width: 0.5)
            Button(action: {
                loginViewModel.sendPasswordResetSubject.send(email)
            }) {
                Text("비밀번호 재설정 이메일 보내기")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(5)
            }
        }
        .padding()
        .alert(isPresented: Binding<Bool>(
            get: { self.loginViewModel.error != nil },
            set: { _ in self.loginViewModel.error = nil }
        ), content: { () -> Alert in
            Alert(title: Text("Error"), message: Text(self.loginViewModel.error?.localizedDescription ?? "Unknown error"), dismissButton: .default(Text("OK"), action: {
                self.loginViewModel.error = nil
            }))
        })
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
