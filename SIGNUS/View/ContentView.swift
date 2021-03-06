//
//  ContentView.swift
//  SwiftUI_SIGNUS
//
//  Created by 김형석 on 2021/01/21.
//

import SwiftUI
import SystemConfiguration

struct ContentView: View {
    @ObservedObject var viewModel = WebViewModel()
    @State var showLoader = false               // 로딩
    @State var sheetOpen = false                // 추가 페이지
    @State var targetUrl = ""                   // 추가 페이지 Url
    
    private let reachability = SCNetworkReachabilityCreateWithName(nil, "soojle.sejong.ac.kr")
    @State private var disconnection = true     // 네트워크 체크
    @State private var showAlert = false        // Alert 표시

    @State var animate = false                  // 로딩 애니메이션
    @State var endAnimate = false               // 로딩 끝
    
    var body: some View {
        ZStack {
            if disconnection {
                Image("logoSmall")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 140, height: 70)
                    .onAppear {
                        var flags = SCNetworkReachabilityFlags()
                        SCNetworkReachabilityGetFlags(self.reachability!, &flags)
                        
                        if self.isNetworkReachable(with: flags) {
                            self.disconnection = false
                            self.showAlert = false
                        } else {
                            self.disconnection = true
                            self.showAlert = true
                        }
                    }
            } else {
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
                            .frame(width: 140, height: 70)
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
        }
        .alert(isPresented: self.$showAlert, content: {
            Alert(
                title: Text("인터넷에 연결할 수 없습니다."),
                message: Text("와이파이 또는 데이터를 통해 인터넷에 연결해주시길 바랍니다."),
                dismissButton: .default(Text("확인"))
            )
        })
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
    
    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) ||
            flags.contains(.connectionOnTraffic)
        let canConnectWithoutInteraction = canConnectAutomatically &&
            !flags.contains(.interventionRequired)
        
        return isReachable && (!needsConnection || canConnectWithoutInteraction)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
