//
//  ContentView.swift
//  SwiftUI_SIGNUS
//
//  Created by 김형석 on 2021/01/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = WebViewModel()
    
    var body: some View {
        ZStack {
            WebView(url: "https://soojle.sejong.ac.kr", viewModel: viewModel)
        }
        .gesture(DragGesture(minimumDistance: 10.0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < -50 {
                    // left
                }
                if value.translation.width > 50 {
                    // right
                }
                if value.translation.height < -50 {
                    // up
                }
                if value.translation.height > 50 {
                    // bottom
                }
            }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
