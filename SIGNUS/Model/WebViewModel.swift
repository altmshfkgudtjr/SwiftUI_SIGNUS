//
//  WebViewModel.swift
//  SwiftUI_SIGNUS
//
//  Created by 김형석 on 2021/01/21.
//

import Foundation
import Combine

// MARK: - 웹뷰 모델: 상위 View와 Data를 연결시켜준다.
class WebViewModel: ObservableObject {
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var sheetOpen = PassthroughSubject<Bool, Never>()
    var targetUrl = PassthroughSubject<String, Never>()
    var valuePublisher = PassthroughSubject<String, Never>()
}

// MARK: - 웹뷰 탐색 타입.
// SIGNUS에서는 사용되지 않음
enum WebViewNavigation {
    case backward, forward, reload
}
