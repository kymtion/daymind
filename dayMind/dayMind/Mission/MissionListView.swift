//
//  missionTable.swift
//  dayMind
//
//  Created by 강영민 on 2023/05/09.
//

import SwiftUI

struct MissionListView: View {
    
    
    let layout: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: layout) {
                    ForEach(missionData) { mission in
                        NavigationLink {
                            DetailView(mission: mission)
                        } label: {
                            MissionRow(mission: mission)
                        }
                    }
                }
            }
            .padding([.top, .leading, .trailing], 15)
            
        }
        .navigationTitle("🎯 미션 리스트")
        
    }
}

struct missionTableView_Previews: PreviewProvider {
    static var previews: some View {
        MissionListView()
    }
}
