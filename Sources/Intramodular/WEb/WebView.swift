//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import WebKit

public struct WebView: View {
    private let configuration: _WebView.Configuration
    private var placeholder: AnyView?
    
    @PersistentObject private var coordinator = _WebView.Coordinator()
    
    public var body: some View {
        _WebView(configuration: configuration, coordinator: coordinator)
            .visible(!coordinator.isLoading)
            .overlay {
                if coordinator.isLoading {
                    placeholder
                }
            }
    }
    
    public init<Placeholder: View>(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.configuration = .init(url: url)
        self.placeholder = placeholder().eraseToAnyView()
    }
    
    public init<Placeholder: View>(
        url: String,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.init(url: URL(string: url)!) {
            placeholder()
        }
    }
}

struct _WebView: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = WKWebView
    
    struct Configuration {
        let url: URL
    }
    
    let configuration: Configuration
    let coordinator: Coordinator
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let view = WKWebView()
        
        view.navigationDelegate = context.coordinator
        
        view.load(URLRequest(url: configuration.url))
        
        return view
    }
    
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
}

extension _WebView {
    class Coordinator: NSObject, ObservableObject, WKNavigationDelegate {
        @Published var isLoading: Bool = true
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if webView.url?.absoluteString != nil {
                isLoading = false
            }
        }
    }
}

#endif

