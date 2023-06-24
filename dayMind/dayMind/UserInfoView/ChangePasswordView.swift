import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var currentPassword = ""

    var body: some View {
        VStack {
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
                if newPassword == confirmPassword {
                    userInfoViewModel.reauthenticate(currentPassword: currentPassword) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            userInfoViewModel.updatePassword(to: newPassword) { error in
                                if let error = error {
                                    errorMessage = error.localizedDescription
                                } else {
                                    errorMessage = "비밀번호가 성공적으로 변경되었습니다."
                                }
                            }
                        }
                    }
                } else {
                    errorMessage = "비밀번호가 일치하지 않습니다."
                }
            }) {
                Text("비밀번호 변경")
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

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
