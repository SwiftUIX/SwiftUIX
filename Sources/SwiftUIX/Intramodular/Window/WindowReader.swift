//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
@_documentation(visibility: internal)
public struct WindowProxy {
    weak var window: AppKitOrUIKitHostingWindowProtocol?
    
    @MainActor
    public var _appKitOrUIKitWindow: AppKitOrUIKitWindow? {
        window
    }
    
    public func orderFrontRegardless() {
        guard let window = window else {
            return assertionFailure()
        }
        
#if os(macOS)
        window.orderFrontRegardless()
#endif
    }
    
    public func _macOS_setMaximumLevel() {
        guard let window = window else {
            return assertionFailure()
        }
        
#if os(iOS) || os(tvOS)
        let currentGreatestWindowLevel = (AppKitOrUIKitWindow._firstKeyInstance?.windowLevel ?? UIWindow.Level.alert)
        
        window.windowLevel = UIWindow.Level(rawValue: currentGreatestWindowLevel.rawValue + 1)
#elseif os(macOS)
        if #available(macOS 13.0, *) {
            window.collectionBehavior.insert(.auxiliary)
        } else {
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
        
        window.level = .screenSaver
#endif
    }
    
    public func dismiss() {
        window?.dismiss()
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension _WindowPresentationController {
    public func bringToFront() {
        self.contentWindow.bringToFront()
    }
    
    public func moveToBack() {
        self.contentWindow.moveToBack()
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
@_documentation(visibility: internal)
public struct WindowReader<Content: View>: View {
    @Environment(\._windowProxy) var _windowProxy: WindowProxy
    
    let content: (WindowProxy) -> Content
    
    public init(@ViewBuilder content: @escaping (WindowProxy) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(_windowProxy)
    }
}

// MARK: - Supplementary

#if os(macOS)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    public func bringToFront() {
        level = .screenSaver
        orderFrontRegardless()
    }
    
    public func moveToBack() {
        level = .normal
        orderOut(nil)
    }
}
#else
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    public func bringToFront() {
        
    }
    
    public func moveToBack() {
        
    }
}
#endif

// MARK: - Auxiliary

extension EnvironmentValues {
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    struct _WindowProxyKey: EnvironmentKey {
        static let defaultValue: WindowProxy = .init(window: nil)
    }
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    var _windowProxy: WindowProxy {
        get {
            self[_WindowProxyKey.self]
        } set {
            self[_WindowProxyKey.self] = newValue
        }
    }
}

#endif
