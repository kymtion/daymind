import SwiftUI

struct UserProfileUpdateView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var nickname: String = ""
    @State private var errorMessage: String = ""
    @State private var showingAlert = false
    @State private var isLoading = false // 로딩 상태 추가
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                TextField("닉네임", text: $nickname)
                    .autocapitalization(.none) // 자동 대문자 변환 방지
                    .keyboardType(.emailAddress)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                Button {
                    if nickname.isEmpty {
                            self.errorMessage = "닉네임을 입력해주세요."
                        } else {
                            self.showingAlert = true
                        }
                } label: {
                    Text("닉네임 변경")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                }
                
                if !errorMessage.isEmpty {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                }
            }
            
            if isLoading {
                LoadingView() // 별도의 로딩 뷰 컴포넌트
            }
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("닉네임 변경"),
                message: Text("정말 닉네임을 변경하시겠습니까?"),
                primaryButton: .default(Text("예")) {
                    self.isLoading = true // 로딩 시작
                        userInfoViewModel.updateProfile(nickname: self.nickname) { error in
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
