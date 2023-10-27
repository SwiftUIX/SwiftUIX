//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Dispatch
import Swift
import SwiftUI
import WebKit

public struct WebView: View {
    private var configuration: _WebView.Configuration
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

extension WebView {
    /// Sets a web view's foreground elements to use a given style.
    public func foregroundStyle(_ foregroundStyle: Color) -> Self {
        then({ $0.configuration.foregroundStyle = foregroundStyle })
    }
    
    /// Sets a web view's foreground elements to use a given style.
    public func foregroundStyle(_ foregroundStyle: Color?) -> Self {
        then({ $0.configuration.foregroundStyle = foregroundStyle })
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

struct _WebView: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = _SwiftUIX_WKWebView
    
    struct Configuration: Hashable {
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
        
        var wantsStyleOverride: Bool {
            foregroundStyle != nil
        }
    }
    
    var configuration: Configuration
    
    @ObservedObject var coordinator: Coordinator
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let view = AppKitOrUIKitViewType()
        
        view._SwiftUIX_configuration = configuration
        
        context.coordinator.webView = view
        
        switch configuration.source {
            case .url:
                break
            case .htmlString(let string):
                view.loadHTMLString(string, baseURL: nil)
        }
        
        return view
    }
    
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view._SwiftUIX_configuration = configuration
        
        switch configuration.source {
            case .url(let url):
                if url != coordinator.activeLoadRequest?.url {
                    coordinator.load(url)
                }
            case .htmlString:
                break
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
            
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
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
            
            guard let webView = webView as? _SwiftUIX_WKWebView else {
                return
            }
            
            webView._SwiftUIX_applyConfiguration()
        }
    }
}

// MARK: - Internal

final class _SwiftUIX_WKWebView: WKWebView, WKNavigationDelegate {
    var _SwiftUIX_configuration: _WebView.Configuration! {
        didSet {
            guard _SwiftUIX_configuration != oldValue else {
                return
            }
            
            _SwiftUIX_applyConfiguration()
        }
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupWebView()
    }
    
    private func setupWebView() {
        navigationDelegate = self
    }
    
    func _SwiftUIX_applyConfiguration() {
        guard let configuration = _SwiftUIX_configuration else {
            return
        }
        
        if configuration.wantsStyleOverride {
            setValue(false, forKey: "drawsBackground")
        }
        
        if let foregroundColor = configuration.foregroundStyle?.toAppKitOrUIKitColor() {
            changeTextColor(to: foregroundColor.toCSSColor())
        }
    }
    
    @discardableResult
    override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        let result = super.loadHTMLString(string, baseURL: baseURL)
        
        DispatchQueue.main.async {
            self.resizeImagesToFitViewport()
        }
        
        return result
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        resizeImagesToFitViewport()
    }
    
    private func resizeImagesToFitViewport() {
        let javascript = """
            var images = document.getElementsByTagName('img');
            for (var i = 0; i < images.length; i++) {
                var image = images[i];
                image.style.maxWidth = '100%';
                image.style.height = 'auto';
            }
        """
        evaluateJavaScript(javascript) { (result, error) in
            if let error = error {
                print("Error injecting JavaScript: \(error.localizedDescription)")
            }
        }
    }
    
    func changeTextColor(
        to cssColor: String
    ) {
        let javascript =
        """
        #imageLiteral(resourceName: "Screenshot 2023-09-10 at 3.08.01 AM.png")
        var style = document.createElement('style');
        style.innerHTML = 'body { color: \(cssColor); }';
        document.head.appendChild(style);
        """
        
        self.robustlyEvaluateJavaScript(javascript) {
            print($0)
        }
    }
}

extension WKWebView {
    func robustlyEvaluateJavaScript(
        _ javaScriptString: String,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        
        let wrappedJSString =
        """
        (() => {
          try {
            const result = (() => {
              \(javaScriptString)
            })();
            return JSON.stringify({ 'data': result });
          } catch (e) {
            return JSON.stringify({ 'error': e.toString() });
          }
        })();
        """

        self.evaluateJavaScript(wrappedJSString) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let jsonString = result as? String,
                  let jsonData = jsonString.data(using: .utf8),
                  let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                completion(.failure(NSError(domain: "WKWebViewExtension", code: -1, userInfo: ["description": "Invalid JSON string"])))
                return
            }
            
            if let errorDescription = jsonObject["error"] as? String {
                completion(.failure(NSError(domain: "WKWebViewExtension", code: -2, userInfo: ["description": errorDescription])))
                return
            }
            
            if let json = jsonObject["data"] {
                completion(.success(json))
            } else {
                completion(.success(nil))
            }
        }
    }
}

// MARK: - Auxiliary

#if os(iOS) || os(tvOS)
extension AppKitOrUIKitColor {
    func toCSSColor() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "rgba(%d, %d, %d, %.2f)", Int(red * 255), Int(green * 255), Int(blue * 255), alpha)
    }
}
#elseif os(macOS)
extension NSColor {
    func toCSSColor() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.colorSpace == .sRGB {
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        } else if let rgbColor = usingColorSpace(.sRGB) {
            rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        } else {
            assertionFailure()
        }
        
        return String(format: "rgba(%d, %d, %d, %.2f)", Int(red * 255), Int(green * 255), Int(blue * 255), alpha)
    }
}
#endif

#endif
