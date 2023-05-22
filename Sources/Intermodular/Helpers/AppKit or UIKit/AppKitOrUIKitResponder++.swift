//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI


#if os(iOS)
extension AppKitOrUIKitResponder {
    private static weak var _firstResponder: AppKitOrUIKitResponder?
    
    public func _nearestResponder(
        where predicate: (AppKitOrUIKitResponder) throws -> Bool
    ) rethrows -> AppKitOrUIKitResponder? {
        if try predicate(self) {
            return self
        }
        
        return try next?._nearestResponder(where: predicate)
    }

    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public static var _SwiftUIX_firstResponder: AppKitOrUIKitResponder? {
        _firstResponder = nil
        
        AppKitOrUIKitApplication.shared.sendAction(#selector(AppKitOrUIKitResponder.acquireFirstResponder(_:)), to: nil, from: nil, for: nil)
        
        return _firstResponder
    }
    
    public var _SwiftUIX_nearestFirstResponder: AppKitOrUIKitResponder? {
        _nearestResponder(where: { $0.isFirstResponder })
    }
    
    @objc private func acquireFirstResponder(_ sender: Any) {
        AppKitOrUIKitResponder._firstResponder = self
    }
}

#elseif os(macOS)
extension AppKitOrUIKitResponder {
    public func _nearestResponder(
        where predicate: (AppKitOrUIKitResponder) throws -> Bool
    ) rethrows -> AppKitOrUIKitResponder? {
        if try predicate(self) {
            return self
        }
        
        return try nextResponder?._nearestResponder(where: predicate)
    }
    
    public var _SwiftUIX_nearestWindow: AppKitOrUIKitWindow? {
        if let controller = self as? NSViewController {
            return controller.view.window
        } else if let view = self as? NSView {
            return view.window ?? view.superview?.window
        } else {
            assertionFailure()
            
            return nil
        }
    }
    
    public var _SwiftUIX_nearestFirstResponder: AppKitOrUIKitResponder? {
        _nearestResponder(where: { _SwiftUIX_nearestWindow?.firstResponder == $0  })
    }
}

extension AppKitOrUIKitResponder {
    private static weak var _firstResponder: AppKitOrUIKitResponder?
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public static var _SwiftUIX_firstResponder: AppKitOrUIKitResponder? {
        NSWindow._firstKeyInstance?.firstResponder
    }
}
#endif

#endif
