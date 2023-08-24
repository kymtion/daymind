//
//  LodingView2.swift
//  dayMind
//
//  Created by 강영민 on 2023/08/24.
//

import SwiftUI

struct LoadingView2: View {
    var body: some View {
        VStack {
            Image("longicon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.5)
                
        }
        .ignoresSafeArea()
    }
}


struct LodingView2_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView2()
    }
}
