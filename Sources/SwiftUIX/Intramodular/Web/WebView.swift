//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Dispatch
import Swift
import SwiftUI
import WebKit

@_documentation(visibility: internal)
public struct WebView: View {
    private var configuration: _WKWebViewRepresentable.Configuration
    private var appKitOrUIKitViewBinding: Binding<_SwiftUIX_WKWebView?>? = nil

    private var placeholder: AnyView?
    
    @State private var coordinator = _WKWebViewRepresentable.Coordinator()
    
    public var body: some View {
        _WebViewBody(
            configuration: configuration,
            appKitOrUIKitViewBinding: appKitOrUIKitViewBinding,
            placeholder: placeholder,
            coordinator: coordinator
        )
        .id(configuration.allowsContentJavaScript)
    }
}

// MARK: - Initializers

extension WebView {
    public init<Placeholder: View>(
        htmlString: String,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.configuration = .init(source: .htmlString(htmlString))
        self.placeholder = placeholder().eraseToAnyView()
    }
    
    public init(
        htmlString: String
    ) {
        self.configuration = .init(source: .htmlString(htmlString))
        self.placeholder = nil
    }
    
    public init<Placeholder: View>(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.configuration = .init(source: .url(url))
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

// MARK: - Modifiers

extension WebView {
    /// Sets a web view's foreground elements to use a given style.
    public func foregroundStyle(
        _ foregroundStyle: Color?
    ) -> Self {
        then({ $0.configuration.foregroundStyle = foregroundStyle })
    }
    
    public func allowsContentJavaScript(
        _ allowsContentJavaScript: Bool?
    ) -> Self {
        then({ $0.configuration.allowsContentJavaScript = allowsContentJavaScript })
    }
}

extension WebView {
    public func _appKitOrUIKitViewBinding(_ binding: Binding<_SwiftUIX_WKWebView?>) -> Self {
        then({ $0.appKitOrUIKitViewBinding = binding })
    }
}

// MARK: - Internal

fileprivate struct _WebViewBody: View {
    let configuration: _WKWebViewRepresentable.Configuration
    let appKitOrUIKitViewBinding: Binding<_SwiftUIX_WKWebView?>?
    let placeholder: AnyView?
    
    @ObservedObject var coordinator: _WKWebViewRepresentable.Coordinator
    
    var body: some View {
        _WKWebViewRepresentable(
            configuration: configuration,
            appKitOrUIKitViewBinding: appKitOrUIKitViewBinding,
            coordinator: coordinator
        )
            .visible(!coordinator.isLoading)
            .overlay {
                switch configuration.source {
                    case .url:
                        if coordinator.isLoading {
                            placeholder
                        }
                    case .htmlString:
                        EmptyView()
                }
            }
            .onChange(of: configuration.source) { _ in
                coordinator.activeLoadRequest = nil
            }
    }
}

struct _WKWebViewRepresentable: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = _SwiftUIX_WKWebView
    
    struct Configuration: Hashable {
        @_documentation(visibility: internal)
        public enum Source: Hashable, Sendable {
            case url(URL)
            case htmlString(String)
            
            var rawValue: String {
                switch self {
                    case .url(let url):
                        return url.absoluteString
                    case .htmlString(let string):
                        return string
                }
            }
        }
        
        let source: Source
        var foregroundStyle: Color?
        var allowsContentJavaScript: Bool?
        
        var wantsStyleOverride: Bool {
            foregroundStyle != nil
        }
    }
    
    var configuration: Configuration
    var appKitOrUIKitViewBinding: Binding<_SwiftUIX_WKWebView?>?

    @ObservedObject var coordinator: Coordinator
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let webpagePreferences = WKWebpagePreferences()
        
        if let allowsContentJavaScript = self.configuration.allowsContentJavaScript {
            if #available(iOS 14, macOS 11, *) {
                webpagePreferences.allowsContentJavaScript = allowsContentJavaScript
            } else {
                // TODO: (@vatsal) handle earlier versions
            }
        }
        
        let webViewConfiguration = WKWebViewConfiguration()
        
        webViewConfiguration.defaultWebpagePreferences = webpagePreferences

        let view = self.appKitOrUIKitViewBinding?.wrappedValue ?? AppKitOrUIKitViewType(frame: .zero, configuration: webViewConfiguration)
        
        view._SwiftUIX_configuration = configuration
        
        context.coordinator.webView = view
        
        if let appKitOrUIKitViewBinding = self.appKitOrUIKitViewBinding {
            DispatchQueue.main.async {
                if appKitOrUIKitViewBinding.wrappedValue !== view {
                    appKitOrUIKitViewBinding.wrappedValue = view
                } else {
                    view._SwiftUIX_setNeedsLayout()
                }
            }
        }
        
        return view
    }
    
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        if view.navigationDelegate !== context.coordinator {
            view.navigationDelegate = context.coordinator
            
            view.reload()
        }
        
        view._SwiftUIX_configuration = configuration
        
        if view._latestSource != configuration.source {
            defer {
                view._latestSource = configuration.source
            }
            
            switch configuration.source {
                case .url(let url):
                    if url != coordinator.activeLoadRequest?.url {
                        coordinator.load(url)
                    }
                case .htmlString(let string):
                    view.loadHTMLString(string, baseURL: nil)
            }
        }
    }
    
    static func dismantleAppKitOrUIKitView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        coordinator.webView = nil
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
}

extension _WKWebViewRepresentable {
    class Coordinator: NSObject, ObservableObject, WKNavigationDelegate {
        struct LoadRequest {
            var url: URL?
            var redirectedURL: URL?
        }
        
        weak var webView: _SwiftUIX_WKWebView? {
            didSet {
                activeLoadRequest = nil
                oldValue?.navigationDelegate = nil
            }
        }
        
        @Published var isLoading: Bool = true
        
        var activeLoadRequest: LoadRequest?
        
        func load(_ url: URL) {
            guard let webView else {
                return
            }
            
            self.activeLoadRequest = nil
            self.activeLoadRequest = .init(url: url, redirectedURL: nil)
            
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            webView.load(URLRequest(url: url))
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
            
            guard let webView = webView as? _SwiftUIX_WKWebView else {
                return
            }
            
            webView._SwiftUIX_applyConfiguration()
        }
    }
}

#endif
