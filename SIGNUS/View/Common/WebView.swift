//
//  WebView.swift
//  SwiftUI_SIGNUS
//
//  Created by 김형석 on 2021/01/21.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import WebKit

// MARK: - WebViewHandlerDelegate - 웹뷰 조정 Delegate 프로토콜 정의
protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
    func receivedStringValueFromWebView(value: String)
}

// MARK: - WebView - 웹뷰 정의
struct WebView: UIViewRepresentable, WebViewHandlerDelegate {
    // Web으로부터 데이터를 전송받았을 때
    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON 데이터가 웹으로부터 옴: \(value)")
    }
    
    func receivedStringValueFromWebView(value: String) {
        print("JSON 데이터가 웹으로부터 옴: \(value)")
    }
    
    // 사용할 변수 및 ObservedObject 선언
    var url: String
    @ObservedObject var viewModel: WebViewModel
    
    // 웹뷰의 Delegate 기능을 조정하는 Coordinator 만드는 함수
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 웹뷰를 만든다.
    func makeUIView(context: Context) -> WKWebView {
        print("웹뷰 생성 시간 : \(url)")
        // 잘못된 url 받았을 때
        if url == "" {
            print("초기 버그")

            let time = DispatchTime.now() + .milliseconds(1000)
            DispatchQueue.main.asyncAfter(deadline: time) {
                // 상위 View에서 로딩 변수 값 false로 변경
                self.viewModel.showLoader.send(false)
                // 모달 종료
                self.viewModel.sheetOpen.send(false)
            }
        }
        
        // 자바스크립 사용을 가능하게 한다.
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        // Here "iOSNative" is our delegate name that we pushed to the website that is being loaded
        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
    
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
       return webView
    }
    
    // 웹뷰를 업데이트 시킨다.
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("웹뷰 업데이트 시간")
//        if let url = URL(string: url) {
//            webView.load(URLRequest(url: url))
//        }
    }
    
    // 웹뷰 Cordinator 선언
    class Coordinator : NSObject, WKNavigationDelegate {
        var parent: WebView
        var delegate: WebViewHandlerDelegate?
        var valueSubscriber: AnyCancellable? = nil
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        
        // 생성자
        init(_ uiWebView: WebView) {
            self.parent = uiWebView
            self.delegate = parent
        }
        
        // 소멸자
        deinit {
            valueSubscriber?.cancel()
            webViewNavigationSubscriber?.cancel()
        }
        
        // 지정된 기본 설정 및 작업 정보를 기반으로 새 콘텐츠를 탐색 할 수있는 권한을 대리인에게 요청 - 탐색 요청 허용 또는 거부
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let host = navigationAction.request.url?.host {
                if host == "soojle.sejong.ac.kr" {
                    return decisionHandler(.allow)
                } else {
                    parent.viewModel.targetUrl.send("\(navigationAction.request.url!)")
                    parent.viewModel.sheetOpen.send(true)
                }
            }
            decisionHandler(.allow)
        }
        
        // 기본 프레임에서 탐색이 시작되었음 - 진행률 추적
        func webView(_ webView: WKWebView,
                     didStartProvisionalNavigation navigation: WKNavigation!) {
            
            print("기본 프레임에서 탐색이 시작되었음")
            // 상위 View에서 로딩 변수 값 true로 변경
            parent.viewModel.showLoader.send(true)
            
            // 탐색바를 사용하기 위한 조치
            /*
            self.webViewNavigationSubscriber = self.parent.viewModel.webViewNavigationPublisher.receive(on: RunLoop.main).sink(receiveValue: { navigation in
                switch navigation {
                    case .backward:
                        if webView.canGoBack {
                            webView.goBack()
                        }
                    case .forward:
                        if webView.canGoForward {
                            webView.goForward()
                        }
                    case .reload:
                        webView.reload()
                }
            })
            */
        }
        
        // 웹보기가 기본 프레임에 대한 내용을 수신하기 시작했음 - 진행률 추적
        func webView(_ webView: WKWebView,
                     didCommit navigation: WKNavigation!) {
            print("내용을 수신하기 시작");
            //  상위 View에서 로딩 변수 값 false로 변경
            parent.viewModel.showLoader.send(false)
        }
        
        // 탐색이 완료 되었음 - 진행률 추적
        func webView(_ webview: WKWebView,
                     didFinish: WKNavigation!) {
            print("탐색이 완료 ===========================")
            //  상위 View에서 로딩 변수 값 false로 변경
            parent.viewModel.showLoader.send(false)
        }
        
        // 초기 탐색 프로세스 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation: WKNavigation!,
                     withError: Error) {
            print("초기 탐색 프로세스 중에 오류가 발생했음")
            print(withError)
            // 상위 View에서 로딩 변수 값 false로 변경
            parent.viewModel.showLoader.send(false)
            // 모달 종료
            parent.viewModel.sheetOpen.send(false)
        }
        
        // 탐색 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            print("탐색 중에 오류가 발생했음")
            // 상위 View에서 로딩 변수 값 false로 변경
            parent.viewModel.showLoader.send(false)
            // 모달 종료
            parent.viewModel.sheetOpen.send(false)
        }
        
        // 웹보기의 콘텐츠 프로세스가 종료되었음 - Error Handler
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            print("프로세스 종료")
            // 상위 View에서 로딩 변수 값 false로 변경
            parent.viewModel.showLoader.send(false)
        }
        
    }
}

// MARK: - Extensions - 웹뷰 Coordinator 확장
extension WebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        // Make sure that your passed delegate is called
        if message.name == "iOSNative" {
            if let body = message.body as? [String: Any?] {
                delegate?.receivedJsonValueFromWebView(value: body)
            } else if let body = message.body as? String {
                delegate?.receivedStringValueFromWebView(value: body)
            }
        }
    }
}
