//
//  DetailView.swift
//  dayMind
//
//  Created by 강영민 on 2023/05/11.
//

import SwiftUI

struct DetailView: View {
    
    var mission: Mission
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(mission.step1a)
                        .font(.system(size: 25, weight: .bold))
                    Text(mission.step1b)
                        .font(.system(size: 20))
                    Text(mission.step1c)
                        .padding()
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(10)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text(mission.step2a)
                        .font(.system(size: 25, weight: .bold))
                    Text(mission.step2b)
                        .font(.system(size: 20))
                    Text(mission.step2c)
                        .padding()
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(10)
                }
                if !mission.step3a.isEmpty || !mission.step3b.isEmpty || !mission.step3c.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(mission.step3a)
                            .font(.system(size: 25, weight: .bold))
                        Text(mission.step3b)
                            .font(.system(size: 20))
                        Text(mission.step3c)
                            .padding()
                            .background(Color(UIColor.lightGray).opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                if !mission.step3a.isEmpty || !mission.step3b.isEmpty || !mission.step3c.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(mission.step4a)
                            .font(.system(size: 25, weight: .bold))
                        Text(mission.step4b)
                            .font(.system(size: 20))
                        Text(mission.step4c)
                            .padding()
                            .background(Color(UIColor.lightGray).opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                Text("인증 방법")
                    .font(.system(size: 30, weight: .bold))
                HStack(spacing: 20){
                    Text("1")
                        .font(.system(size: 30, weight: .bold))
                    Text(mission.confirmmethod1)
                }
                HStack(spacing: 20){
                    Text("2")
                        .font(.system(size: 30, weight: .bold))
                    Text(mission.confirmmethod2)
                }
                
            }
            .padding(20)

        }

        }
    }
    struct DetailView_Previews: PreviewProvider {
        static var previews: some View {
            DetailView(mission: missionData[0])
        }
    }
