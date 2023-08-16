import SwiftUI

struct UserInfoView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var showingReauthentication = false
    @State private var navigateToAccountSettings = false
    
    var body: some View {
        
       
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HStack {
                        Text("😀")
                            .font(.system(size: 30))
                        Text("\(userInfoViewModel.displayName)")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Text("💰")
                                .font(.system(size: 50))
                            Text("현재 보유 잔액")
                                .font(.system(size: 14, weight: .semibold))
                                .opacity(0.7)
                            Text("\(userInfoViewModel.balance.formattedWithComma())원")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Spacer()
                        VStack(spacing: 5) {
                            Text("💵")
                                .font(.system(size: 50))
                            Text("예치금 총액")
                                .font(.system(size: 14, weight: .semibold))
                                .opacity(0.7)
                            Text("\(userInfoViewModel.calculateOtherAmounts().formattedWithComma())원")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Spacer()
                    }
                    
                    Text("\(userInfoViewModel.email)")
                        .font(.system(size: 18, weight: .regular))
                        .opacity(0.7)
                    
                    
                    
                    
                    
                }
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 10)
                    .foregroundColor(.gray.opacity(0.1))
                
                VStack(alignment: .leading, spacing: 20) {
                    NavigationLink {
                        AccountSetting().environmentObject(userInfoViewModel)
                    }label: {
                        HStack {
                            Text("계정 설정")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }
                    NavigationLink {
                        MissionRecordView().environmentObject(userInfoViewModel)
                        
                    }label: {
                        HStack {
                            Text("미션 결과 저장소")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.7))
                            
                        }
                        
                    }
                    
                }
                .padding()
            }
        }
    }


struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoView()
            .environmentObject(UserInfoViewModel())
    }
}
