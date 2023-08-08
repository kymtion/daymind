
import SwiftUI
import Kingfisher

struct DetailView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    
    var mission: Mission? {
        missionViewModel.selectedMission
    }
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
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
                        VStack(spacing: 30) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(mission.step1a)
                                    .font(.system(size: 23, weight: .bold))
                                Text(mission.step1b)
                                    .font(.system(size: 18))
                                Text(mission.step1c)
                                    .padding()
                                    .font(.system(size: 15))
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(mission.step2a)
                                    .font(.system(size: 23, weight: .bold))
                                Text(mission.step2b)
                                    .font(.system(size: 18))
                                
                                Text(mission.step2c)
                                    .padding()
                                    .font(.system(size: 15))
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                
                            }
                            .padding(.horizontal)
                            
                            if !mission.step3a.isEmpty || !mission.step3b.isEmpty || !mission.step3c.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(mission.step3a)
                                        .font(.system(size: 23, weight: .bold))
                                    
                                    Text(mission.step3b)
                                        .font(.system(size: 18))
                                    
                                    Text(mission.step3c)
                                        .padding()
                                        .font(.system(size: 15))
                                        .frame(width: UIScreen.main.bounds.width * 0.9)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 10)
                            
                            Text("인증 방법")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 30) {
                                HStack(spacing: 10) {
                                    Text("1")
                                        .font(.system(size: 30, weight: .bold))
                                    Text(mission.confirmmethod1)
                                        .frame(width: UIScreen.main.bounds.width * 0.8)
                                        .font(.system(size: 15))
                                }
                                
                                HStack(spacing: 10) {
                                    Text("2")
                                        .font(.system(size: 30, weight: .bold))
                                    Text(mission.confirmmethod2)
                                        .frame(width: UIScreen.main.bounds.width * 0.8)
                                        .font(.system(size: 15))
                                }
                            }
                        }
                        .foregroundColor(.black)
                        
                        Spacer()
                            .frame(height: 50)
                        
                        VStack(alignment: .center, spacing: 50) {
                            
                            if !mission.examplePhoto1.isEmpty && !mission.examplePhoto2.isEmpty && !mission.examplePhoto3.isEmpty {
                                
                                VStack(alignment: .center, spacing: 12) {
                                    Text(mission.examplePhoto1)
                                        .font(.system(size: 23, weight: .bold))
                                    Group {
                                        if let url = missionViewModel.imageURL {
                                            KFImage(url)
                                                .resizable()
                                                .onFailure { error in
                                                    Text("Unable to load image")
                                                }
                                                .scaledToFit()
                                                .frame(width: UIScreen.main.bounds.width * 0.5)
                                                .cornerRadius(10)
                                        } else {
                                            Text("Loading...")
                                        }
                                    }
                                    Text(mission.examplePhoto3)
                                        .font(.system(size: 15))
                                    
                                }.onAppear {
                                    missionViewModel.fetchImageURL(from: mission.examplePhoto2)
                                }
                            }
                            
                            Text(mission.description)
                                .padding(25)
                                .font(.system(size: 15))
                                .background(Color.gray.opacity(0.1))
                            
                            Button {
                                missionViewModel.showTimeSettingView = true
                            } label: {
                                Text("시 작")
                                    .padding(10)
                                    .font(.system(size: 23, weight: .bold))
                                    .frame(width: UIScreen.main.bounds.width * 0.4)
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .fullScreenCover(isPresented: $missionViewModel.showTimeSettingView) {
                                TimeSettingView()
                                    .environmentObject(missionViewModel)
                            }
                        }
                        .foregroundColor(.black)
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(mission: missionData[1])
//                   .environmentObject(MissionViewModel())
//    }
//}
