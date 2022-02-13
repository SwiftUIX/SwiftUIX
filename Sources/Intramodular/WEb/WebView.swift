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
    
    @State private var coordinator = _WebView.Coordinator()
    
    public var body: some View {
        _WebViewContainer(
            configuration: configuration,
            placeholder: placeholder,
            coordinator: coordinator
        )
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

struct _WebViewContainer: View {
    let configuration: _WebView.Configuration
    let placeholder: AnyView?

    @ObservedObject var coordinator: _WebView.Coordinator

    var body: some View {
        _WebView(configuration: configuration, coordinator: coordinator)
            .visible(!coordinator.isLoading)
            .overlay {
                if coordinator.isLoading {
                    placeholder
                }
            }
            .onChange(of: configuration.url) { _ in
                coordinator.activeLoadRequest = nil
            }
    }
}

struct _WebView: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = WKWebView
    
    struct Configuration {
        let url: URL
    }
    
    let configuration: Configuration

    @ObservedObject var coordinator: Coordinator
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let view = WKWebView()

        context.coordinator.webView = view

        return view
    }
    
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        if configuration.url != coordinator.activeLoadRequest?.url {
            coordinator.load(configuration.url)
        }
    }

    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator) {
        coordinator.webView = nil
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
}

extension _WebView {
    class Coordinator: NSObject, ObservableObject, WKNavigationDelegate {
        struct LoadRequest {
            var url: URL?
            var redirectedURL: URL?
        }

        weak var webView: WKWebView? {
            didSet {
                activeLoadRequest = nil
                oldValue?.navigationDelegate = nil
                webView?.navigationDelegate = self
            }
        }

        @Published var isLoading: Bool = true

        var activeLoadRequest: LoadRequest?

        func load(_ url: URL) {
            self.activeLoadRequest = nil
            self.activeLoadRequest = .init(url: url, redirectedURL: nil)

            isLoading = true

            webView?.load(URLRequest(url: url))
        }

        func webView(
            _ webView: WKWebView,
            didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
        ) {
            self.activeLoadRequest?.redirectedURL = webView.url
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            if webView.url?.absoluteString != nil {
                isLoading = false
            }
        }
    }
}

#endif
