
import SwiftUI

struct DetailView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    
    var mission: Mission? {
        missionViewModel.selectedMission
    }
    var body: some View {
        
        
        if let mission = mission {
            VStack {
                HStack {
                    Button {
                        missionViewModel.showDetailView.toggle()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                            Text("Back")
                                .font(.system(size: 18, weight: .regular))
                            Spacer()
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                ScrollView {
                    VStack(spacing: 35) {
                        
                        VStack(spacing: 10) {
                            
                            Text("강력한 동기부여가 필요하다면,\n미션에 돈을 걸어보세요!")
                                .font(.system(size: 20, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Image(systemName: "lightbulb.circle")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.blue)
                                .aspectRatio(contentMode: .fit)
                                .font(.system(size: 40))
                                .opacity(0.9)
                            
                            Text("혼자서는 지키지 못했던 약속, 이제는 돈을 걸어서 \n당신의 하루를 스스로 통제하세요!")
                                .font(.system(size: 16, weight: .regular))
                                .multilineTextAlignment(.center)
                                .opacity(0.7)
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "1.square")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.green)
                                    .aspectRatio(contentMode: .fit)
                                    .font(.system(size: 30))
                                    .opacity(0.9)
                                Text(mission.step1a)
                                    .font(.system(size: 20, weight: .bold))
                            }
                            Text(mission.step1b)
                                .font(.system(size: 14))
                                .opacity(0.8)
                        }
                        .padding(.horizontal, 20)
                        
                        if !mission.step2a.isEmpty || !mission.step2b.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "2.square")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.green)
                                        .aspectRatio(contentMode: .fit)
                                        .font(.system(size: 30))
                                        .opacity(0.9)
                                    Text(mission.step2a)
                                        .font(.system(size: 20, weight: .bold))
                                }
                                Text(mission.step2b)
                                    .font(.system(size: 14))
                                    .opacity(0.8)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("인증 안내")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                            }
                            
                            
                            HStack(spacing: 5) {
                                Image(systemName: "1.lane")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.blue)
                                    .aspectRatio(contentMode: .fit)
                                    .font(.system(size: 30))
                                    .opacity(0.9)
                                Text(mission.verificationGuide1)
                                    .font(.system(size: 14))
                                    .frame(width: UIScreen.main.bounds.width * 0.75)
                                    .opacity(0.8)
                            }
                            Divider()
                            HStack(spacing: 5) {
                                Image(systemName: "2.lane")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.blue)
                                    .aspectRatio(contentMode: .fit)
                                    .font(.system(size: 30))
                                    .opacity(0.9)
                                
                                Text(mission.verificationGuide2)
                                    .font(.system(size: 14))
                                    .frame(width: UIScreen.main.bounds.width * 0.75)
                                    .opacity(0.8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            Image(mission.examplePhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                .overlay(
                                    Rectangle() // 외곽선을 위한 직사각형
                                        .stroke(Color.gray.opacity(0.8), lineWidth: 3) // 파란색, 두께 2의 선
                                )
                                .opacity(0.8)
                            Text("인증 예시")
                                .font(.system(size: 20, weight: .medium))
                            
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            HStack {
                                Text("환급 안내")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                            }
                            
                            
                            VStack(alignment: .leading) {
                                Text(mission.refundGuide1)
                                    .font(.system(size: 14))
                                    .opacity(0.8)
                                    .padding(.top, 15)
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 5)
                                
                                Divider()
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 0)
                                
                                if !mission.refundGuide2.isEmpty {
                                    Text(mission.refundGuide2)
                                        .font(.system(size: 14))
                                        .opacity(0.8)
                                        .padding(.top, 5)
                                        .padding(.horizontal, 15)
                                        .padding(.bottom, 15)
                                    
                                    
                                }
                                
                                
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green.opacity(0.8), lineWidth: 2) // 외곽 둥근 선 설정
                            )
                        }
                        .padding(.horizontal, 25)
                        
                        VStack(spacing: 15) {
                            HStack {
                                Text("주의사항")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                            }
                            VStack(alignment: .leading) {
                                Text(mission.warnings1)
                                    .font(.system(size: 14))
                                    .opacity(0.8)
                                    .padding(.top, 15)
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 5)
                                
                                Divider()
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 0)
                                
                                
                                Text(mission.warnings2)
                                    .font(.system(size: 14))
                                    .opacity(0.8)
                                    .padding(.top, 5)
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 15)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.8), lineWidth: 2) // 외곽 둥근 선 설정
                            )
                        }
                        .padding(.horizontal, 25)
                        
                        BlueButton(title: "시 작") {
                            missionViewModel.showTimeSettingView = true
                        }
                        .fullScreenCover(isPresented: $missionViewModel.showTimeSettingView) {
                            TimeSettingView()
                                .environmentObject(missionViewModel)
                        }
                    }
                    
                }
                
            }
        }
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let missionViewModel = MissionViewModel()
        missionViewModel.selectedMission = missionData[1]
        return DetailView()
            .environmentObject(missionViewModel)
    }
}
