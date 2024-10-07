//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Dispatch
import Swift
import SwiftUI
import WebKit

public final class _SwiftUIX_WKWebView: WKWebView, WKNavigationDelegate {
    var _SwiftUIX_configuration: _WKWebViewRepresentable.Configuration! {
        didSet {
            guard _SwiftUIX_configuration != oldValue else {
                return
            }
            
            _SwiftUIX_applyConfiguration()
        }
    }
    
    var _latestSource: _WKWebViewRepresentable.Configuration.Source?
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
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
            _changeTextColor(to: foregroundColor.toCSSColor())
        }
    }
    
    @discardableResult
    public override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        let result = super.loadHTMLString(string, baseURL: baseURL)
        
        Task { @MainActor in
            self.resizeImagesToFitViewport()
        }
        
        return result
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
}

extension _SwiftUIX_WKWebView {
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
    
    fileprivate func _changeTextColor(
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
extension AppKitOrUIKitColor {
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
