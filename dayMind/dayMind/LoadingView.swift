//
//  LodingView.swift
//  dayMind
//
//  Created by 강영민 on 2023/07/20.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
            ProgressView("Loading...")
        }
    }
   


struct LodingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
