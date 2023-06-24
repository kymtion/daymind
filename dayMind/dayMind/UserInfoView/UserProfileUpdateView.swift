
import SwiftUI

struct UserProfileUpdateView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var displayName: String = ""
    @State private var errorMessage: String = ""
    
    
    var body: some View {
        VStack {
            TextField("이름(닉네임)", text: $displayName)
            Button(action: {
                userInfoViewModel.updateProfile(userName: self.displayName) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Update Profile")
            }
            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
            }
        }
        .onAppear {
            self.displayName = userInfoViewModel.displayName
        }
    }
}
    struct UserProfileUpdateView_Previews: PreviewProvider {
        static var previews: some View {
            UserProfileUpdateView()
        }
    }
