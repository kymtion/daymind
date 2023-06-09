//
//  MissionListCell.swift
//  dayMind
//
//  Created by 강영민 on 2023/05/09.
//

import SwiftUI

struct MissionRow: View {
    
    var mission: Mission
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: mission.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(mission.color)
                .frame(width: 70, height: 70)
            
            
            Text(mission.name)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(Color.primary)
            
        }
        .padding()
        .frame(width: 170, height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10).stroke(Color.primary, lineWidth: 0)
            
            
    
            
        }
    }
}
struct MissionListCell_Previews: PreviewProvider {
    static var previews: some View {
        MissionRow(mission: missionData[0])
    }
}
