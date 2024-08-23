//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Combine
import SwiftUI

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitWindow {
    public static var _SwiftUIX_allInstances: [AppKitOrUIKitWindow] {
        #if os(macOS)
        return AppKitOrUIKitApplication.shared.windows
        #else
        return AppKitOrUIKitApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows ?? []
        #endif
    }
    
    public static var _SwiftUIX_largestInstanceByArea: AppKitOrUIKitWindow? {
        _SwiftUIX_allInstances.max(by: { ($0.frame.size.width * $0.frame.size.height) < ($1.frame.size.width * $1.frame.size.height) })
    }

    public static var _firstKeyInstance: AppKitOrUIKitWindow? {
        #if os(iOS) || os(macOS)
        return AppKitOrUIKitApplication.shared.firstKeyWindow
        #else
        return AppKitOrUIKitApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        #endif
    }
    
    public func _forceFirstResponderToResign() {
        #if os(macOS)
        makeFirstResponder(nil)
        #else
        resignFirstResponder()
        endEditing(true)
        #endif
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
extension AppKitOrUIKitWindow {
    public var _SwiftUIX_contentView: AppKitOrUIKitView? {
        self
    }

    public var _SwiftUIX_macOS_titleBarHeight: CGFloat? {
        nil
    }
}
#elseif os(macOS)
extension AppKitOrUIKitWindow {
    public var _SwiftUIX_contentView: AppKitOrUIKitView? {
        contentView
    }
    
    public var _SwiftUIX_macOS_titleBarHeight: CGFloat? {
        guard let windowFrame = self._SwiftUIX_contentView?.superview?.frame, let contentFrame = self.contentView?.frame else {
            return nil
        }
        
        let titleBarHeight = windowFrame.height - contentFrame.height
        
        return titleBarHeight > 0 ? titleBarHeight : nil
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitWindow {
    @objc open var alphaValue: CGFloat {
        get {
            self.rootViewController?.view.alpha ?? 1
        } set {
            self.rootViewController?.view.alpha = newValue
        }
    }
}
#endif

extension AppKitOrUIKitWindow {
    public var _SwiftUIX_isInRegularDisplay: Bool {
        guard !isHidden else {
            return false
        }
        
        guard alphaValue != 0.0 else {
            return false
        }
        
        guard !_isNSStatusBarWindow else {
            return false
        }
        
        return true
    }

    public var _isSwiftUIWindow: Bool {
        let className: String = NSStringFromClass(type(of: self))
        
        if className == "SwiftUI.SwiftUIWindow" {
            return true
        }
        
        if className == "SwiftUI.AppKitWindow" {
            return true
        }
        
        if className.hasPrefix("SwiftUI.") {
            return true
        }
        
        return false
    }
    
    public var _isNSStatusBarWindow: Bool {
        NSStringFromClass(type(of: self)).contains("NSStatusBarWindow")
    }
}

extension AppKitOrUIKitWindow {
    public struct _TransitionPhasePublisher: Publisher {
        @_documentation(visibility: internal)
public enum Output {
            case didBecomeKey
            case didResignKey
            case willClose
        }
        
        public typealias Failure = Never
        
        public init() {
            
        }
        
        public func receive<S: Subscriber>(
            subscriber: S
        ) where S.Input == Output, S.Failure == Failure {
            let notificationCenter = NotificationCenter.default
            
            #if os(iOS) || os(tvOS) || os(visionOS)
            let publisher = Publishers.MergeMany(
                notificationCenter.publisher(for: UIWindow.didBecomeKeyNotification).map { _ in Output.didBecomeKey },
                notificationCenter.publisher(for: UIWindow.didResignKeyNotification).map { _ in Output.didResignKey }
            )
            #elseif os(macOS)
            let publisher = Publishers.MergeMany(
                notificationCenter.publisher(for: NSWindow.didBecomeKeyNotification).map { _ in Output.didBecomeKey },
                notificationCenter.publisher(for: NSWindow.didResignKeyNotification).map { _ in Output.didResignKey },
                notificationCenter.publisher(for: NSWindow.willCloseNotification).map { _ in Output.willClose }
            )
            #endif
            
            publisher.receive(subscriber: subscriber)
        }
    }
}

#endif
