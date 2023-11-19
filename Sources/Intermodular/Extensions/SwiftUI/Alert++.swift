//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension Alert {
    public init(
        title: String,
        message: String? = nil,
        dismissButtonTitle: String? = nil
    ) {
        self.init(
            title: Text(title),
            message: message.map({ Text($0) }),
            dismissButton: dismissButtonTitle.map({ .cancel(Text($0)) })
        )
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Alert {
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public func show() {
        _ = _AlertWindow(alert: self)
    }
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public func present() {
        show()
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
private class _AlertWindow: UIWindow {
    struct HostingView: View {
        @State var isPresenting: Bool = true
        
        let alert: Alert
        
        var body: some View {
            ZeroSizeView()
                .alert(isPresented: $isPresenting, content: { alert })
        }
    }
    
    class HostingController: UIHostingController<HostingView> {
        var window: _AlertWindow?
        
        init(window: _AlertWindow) {
            self.window = window
            
            super.init(rootView: .init(alert: window.alert))
            
            view.backgroundColor = .clear
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag) {
                DispatchQueue.main.async {
                    self.window = nil
                }
            }
        }
    }
    
    let alert: Alert
    
    init(alert: Alert) {
        self.alert = alert
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let scene = window.windowScene {
            super.init(windowScene: scene)
            
            windowLevel = .init(rawValue: window.windowLevel.rawValue + 1)
        } else {
            assertionFailure()
            
            super.init(frame: .zero)
        }
        
        rootViewController = HostingController(window: self)
        
        makeKeyAndVisible()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
