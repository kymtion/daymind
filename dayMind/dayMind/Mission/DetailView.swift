
import SwiftUI
import Kingfisher

struct DetailView: View {
    
    @EnvironmentObject var missionViewModel: MissionViewModel
    var mission: Mission
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(mission.step1a)
                            .font(.system(size: 25, weight: .bold))
                        Text(mission.step1b)
                            .font(.system(size: 20))
                        Text(mission.step1c)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)

                    }
                    .padding(.horizontal)

                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(mission.step2a)
                            .font(.system(size: 25, weight: .bold))
                        Text(mission.step2b)
                            .font(.system(size: 20))

                        Text(mission.step2c)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)

                    }
                    .padding(.horizontal)
                    
                    if !mission.step3a.isEmpty || !mission.step3b.isEmpty || !mission.step3c.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(mission.step3a)
                                .font(.system(size: 25, weight: .bold))

                            Text(mission.step3b)
                                .font(.system(size: 20))

                            Text(mission.step3c)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)

                        }
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 10)
                    
                    Text("인증 방법")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.black)

                    
                    VStack(alignment: .leading, spacing: 30) {
                        HStack(spacing: 10) {
                            Text("1")
                                .font(.system(size: 30, weight: .bold))
                            Text(mission.confirmmethod1)
                                .frame(width: UIScreen.main.bounds.width * 0.8)
                        }
                        

                        HStack(spacing: 10) {
                            Text("2")
                                .font(.system(size: 30, weight: .bold))
                            Text(mission.confirmmethod2)
                                .frame(width: UIScreen.main.bounds.width * 0.8)
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
                                .font(.system(size: 25, weight: .bold))
                            Group {
                                if let url = missionViewModel.imageURL {
                                    KFImage(url)
                                        .resizable()
                                        .onFailure { error in
                                            Text("Unable to load image")
                                        }
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width * 0.7)
                                        .cornerRadius(10)
                                } else {
                                    Text("Loading...")
                                }
                            }
                            Text(mission.examplePhoto3)
                            
                        }.onAppear {
                            missionViewModel.fetchImageURL(from: mission.examplePhoto2)
                            
                            
                        }
                        
                    }
                    Text(mission.description)
                        .padding(25)
                        .background(Color.gray.opacity(0.1))
                    
                    NavigationLink {
                        TimeSettingView(mission: mission)
                    } label: {
                        Text("시작 하기")
                            .padding()
                            .font(.system(size: 25, weight: .bold))
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                            .background(Color(red: 242 / 255, green: 206 / 255, blue: 102 / 255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    

                    
                }
                .foregroundColor(.black)
            }
            .padding(.vertical)
        }
        
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(mission: missionData[1])
                   .environmentObject(MissionViewModel())
    }
}
