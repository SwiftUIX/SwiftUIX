//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import SwiftUI

@_documentation(visibility: internal)
public class _AppPhaseMonitor: NSObject {
    @_documentation(visibility: internal)
public enum Phase {
        case uninitialized
        case initialized
    }
    
    static let shared = _AppPhaseMonitor()
    
    private var swizzled: Bool = false
    
    public var phase: Phase = .uninitialized
    
    private override init() {
        super.init()
        
        setupNotification()
        swizzleApplicationDidFinishLaunching()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidFinishLaunching), name: AppKitOrUIKitApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func applicationDidFinishLaunching() {
        phase = .initialized
    }
    
    private func swizzleApplicationDidFinishLaunching() {
        let originalSelector = #selector(AppKitOrUIKitApplicationDelegate.applicationDidFinishLaunching(_:))
        let swizzledSelector = #selector(swizzled_applicationDidFinishLaunching(_:))
        
        guard let originalMethod = class_getInstanceMethod(AppKitOrUIKitApplication.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(AppKitOrUIKitApplication.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
        swizzled = true
    }
    
    @objc private func swizzled_applicationDidFinishLaunching(
        _ notification: Notification
    ) {
        guard swizzled else {
            assertionFailure()
            
            return
        }
        
        swizzled_applicationDidFinishLaunching(notification)
        
        NotificationCenter.default.post(name: AppKitOrUIKitApplication.didBecomeActiveNotification, object: nil)
    }
}

#if os(iOS)
extension UIApplication {
    open override var next: UIResponder? {
        _ = _AppPhaseMonitor.shared
        
        return super.next
    }
}
#elseif os(macOS)
extension NSApplication {
    open override var nextResponder: NSResponder? {
        get {
            _ = _AppPhaseMonitor.shared
            
            return super.nextResponder
        } set {
            super.nextResponder = newValue
        }
    }
}
#endif

#endif
