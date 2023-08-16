import SwiftUI

struct UserInfoView: View {
    
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @State private var showingReauthentication = false
    @State private var navigateToAccountSettings = false
    
    var body: some View {
        
       
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HStack(spacing: 15) {
                        Text("🌏")
                            .font(.system(size: 50))
                            .opacity(0.85)
                        VStack(alignment: .leading) {
                            Text("\(userInfoViewModel.displayName)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            Text("\(userInfoViewModel.email)")
                                .font(.system(size: 16, weight: .regular))
                                .opacity(0.7)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 15)
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Text("💰")
                                .font(.system(size: 40))
                                .opacity(0.85)
                            Text("현재 보유 잔액")
                                .font(.system(size: 13, weight: .semibold))
                                .opacity(0.7)
                            Text("\(userInfoViewModel.balance.formattedWithComma())원")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Spacer()
                        VStack(spacing: 5) {
                            Text("💵")
                                .font(.system(size: 40))
                                .opacity(0.85)
                            Text("예치금 총액")
                                .font(.system(size: 13, weight: .semibold))
                                .opacity(0.7)
                            Text("\(userInfoViewModel.calculateOtherAmounts().formattedWithComma())원")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Spacer()
                    }
                    
                    
                    
                }
                .padding(.bottom, 20)
                
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
                        
                    } label: {
                        HStack {
                            Text("환급 및 벌금 내역")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.7))
                            
                        }
                    }
                    NavigationLink {
                        TransactionHistoryView().environmentObject(userInfoViewModel)
                        
                    } label: {
                        HStack {
                            Text("충전 및 출금 현황")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.7))
                            
                        }
                    }
                    
                    NavigationLink {
                        WithdrawalView().environmentObject(userInfoViewModel)
                        
                    } label: {
                        HStack {
                            Text("잔액 출금")
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
