import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var showConfirmationAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Text("Delete Account")
                .font(.largeTitle)
                .padding(.bottom, 50)
            
            SecureField("Enter your password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 24)
            
            Button(action: {
                userInfoViewModel.reauthenticate(currentPassword: password) { error in
                    if let error = error {
                        errorMessage = "Reauthentication failed: \(error.localizedDescription)"
                        showErrorAlert = true
                    } else {
                        showConfirmationAlert = true
                    }
                }
            }) {
                Text("Reauthenticate")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(password.isEmpty)
            
            if showConfirmationAlert {
                Button(action: {
                    userInfoViewModel.deleteUser { error in
                        if let error = error {
                            errorMessage = "Failed to delete account: \(error.localizedDescription)"
                            showErrorAlert = true
                        } else {
                            errorMessage = "Account successfully deleted."
                            showErrorAlert = true
                        }
                    }
                }) {
                    Text("Delete Account")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
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
