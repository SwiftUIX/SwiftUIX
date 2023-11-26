//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
extension AppKitOrUIKitResponder {
    private static weak var _firstResponder: AppKitOrUIKitResponder?
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public static var _SwiftUIX_firstResponder: AppKitOrUIKitResponder? {
        _firstResponder = nil
        
        AppKitOrUIKitApplication.shared.sendAction(#selector(AppKitOrUIKitResponder.acquireFirstResponder(_:)), to: nil, from: nil, for: nil)
        
        return _firstResponder
    }
    
    public var _SwiftUIX_isFirstResponder: Bool {
        isFirstResponder
    }
    
    public var _SwiftUIX_nearestFirstResponder: AppKitOrUIKitResponder? {
        _SwiftUIX_nearestResponder(where: { $0.isFirstResponder })
    }
    
    public func _SwiftUIX_nearestResponder(
        where predicate: (AppKitOrUIKitResponder) throws -> Bool
    ) rethrows -> AppKitOrUIKitResponder? {
        if try predicate(self) {
            return self
        }
        
        return try next?._SwiftUIX_nearestResponder(where: predicate)
    }
    
    @objc private func acquireFirstResponder(_ sender: Any) {
        AppKitOrUIKitResponder._firstResponder = self
    }
    
    @discardableResult
    public func _SwiftUIX_becomeFirstResponder() -> Bool {
        self.becomeFirstResponder()
    }
    
    @discardableResult
    public func _SwiftUIX_resignFirstResponder() -> Bool {
        self.resignFirstResponder()
    }
}
#elseif os(macOS)
extension AppKitOrUIKitResponder {
    private static weak var _firstResponder: AppKitOrUIKitResponder?
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public static var _SwiftUIX_firstResponder: AppKitOrUIKitResponder? {
        NSWindow._firstKeyInstance?.firstResponder
    }
    
    public var _SwiftUIX_isFirstResponder: Bool {
        Self._SwiftUIX_firstResponder === self
    }
    
    public var _SwiftUIX_nearestFirstResponder: AppKitOrUIKitResponder? {
        _SwiftUIX_nearestResponder(where: { _SwiftUIX_nearestWindow?.firstResponder == $0  })
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
    
    public func _SwiftUIX_nearestResponder(
        where predicate: (AppKitOrUIKitResponder) throws -> Bool
    ) rethrows -> AppKitOrUIKitResponder? {
        if try predicate(self) {
            return self
        }
        
        return try nextResponder?._SwiftUIX_nearestResponder(where: predicate)
    }
    
    @discardableResult
    public func _SwiftUIX_becomeFirstResponder() -> Bool {
        if let _self = self as? NSView {
            if let window = _self.window {
                return window.makeFirstResponder(self)
            } else {
                return false
            }
        } else if let _self = self as? NSViewController {
            return _self._SwiftUIX_makeFirstResponder(_self)
        } else {
            assertionFailure()
            
            return false
        }
    }
    
    @discardableResult
    public func _SwiftUIX_resignFirstResponder() -> Bool {
        guard let window = _SwiftUIX_nearestWindow else {
            return false
        }
        
        if _SwiftUIX_isFirstResponder {
           return window.makeFirstResponder(nil)
        } else {
            return true
        }
    }
}
#endif

#endif
