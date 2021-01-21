//
//  ContentView.swift
//  SwiftUI_SIGNUS
//
//  Created by 김형석 on 2021/01/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = WebViewModel()
    @State var showLoader = false   // 로딩
    @State var sheetOpen = false    // 추가 페이지
    @State var targetUrl = ""       // 추가 페이지 Url
    
    @State var animate = false
    @State var endAnimate = false
    
    var body: some View {
        ZStack {
            WebView(url: "https://soojle.sejong.ac.kr", viewModel: viewModel)
                .sheet(isPresented: $sheetOpen) {
                    ZStack {
                        WebView(url: targetUrl, viewModel: viewModel)
                        
                        if showLoader {
                            Loader()
                        }
                    }
                }
            
            if !endAnimate {
                Image("logoSmall")
                    .resizable()
                    .renderingMode(.original)
                    .scaleEffect(animate ? 1 : 0)
            }
        }
        .onAppear(perform: animateSplash)
        .onReceive(self.viewModel.showLoader.receive(on: RunLoop.main)) { value in
            self.showLoader = value
        }
        .onReceive(self.viewModel.targetUrl.receive(on: RunLoop.main)) { value in
            self.targetUrl = value
        }
        .onReceive(self.viewModel.sheetOpen.receive(on: RunLoop.main)) { value in
            let time = DispatchTime.now() + .milliseconds(0)
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.sheetOpen = value
            }
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
    
    func animateSplash() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animation.easeOut(duration: 2)) {
                animate.toggle()
            }
            
            withAnimation(Animation.easeOut(duration: 1)) {
                endAnimate.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
