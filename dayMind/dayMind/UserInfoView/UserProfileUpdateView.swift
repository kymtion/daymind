import SwiftUI

struct UserProfileUpdateView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var displayName: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAlert = false
    @State private var isLoading = false // 로딩 상태 추가
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                TextField("이름(닉네임)", text: $displayName)
                    .autocapitalization(.none) // 자동 대문자 변환 방지
                    .keyboardType(.emailAddress)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                Button {
                    self.showingAlert = true
                } label: {
                    Text("이름 변경")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                }
                
                if !errorMessage.isEmpty {
                    Text("Error: \(errorMessage)")
                }
            }
            
            if isLoading {
                LoadingView() // 별도의 로딩 뷰 컴포넌트
            }
        }
        .padding()
        .onAppear {
            self.displayName = userInfoViewModel.displayName
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("이름 변경"),
                message: Text("정말 이름(닉네임)을 변경하시겠습니까?"),
                primaryButton: .default(Text("예")) {
                    self.isLoading = true // 로딩 시작
                        userInfoViewModel.updateProfile(userName: self.displayName) { error in
                            self.isLoading = false // 로딩 종료
                            if let error = error {
                                self.errorMessage = error.localizedDescription
                            } else {
                                self.presentationMode.wrappedValue.dismiss() // 상위 뷰로 돌아감
                            
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

    struct UserProfileUpdateView_Previews: PreviewProvider {
        static var previews: some View {
            UserProfileUpdateView()
                .environmentObject(UserInfoViewModel())
        }
    }
