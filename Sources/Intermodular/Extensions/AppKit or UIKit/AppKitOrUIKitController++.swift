//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitViewController {
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public var _SwiftUIX_firstResponderController: AppKitOrUIKitViewController? {
        guard let firstResponder = _SwiftUIX_findFirstResponder() else {
            return nil
        }
        
        if firstResponder === view {
            return self 
        } else if firstResponder === self {
            return self
        } else {
            return firstResponder.nearestViewController
        }
    }
    
    public func _SwiftUIX_makeFirstResponder(
        _ responder: AppKitOrUIKitResponder?
    ) {
        if let responder {
            if responder === self {
                if view.canBecomeFirstResponder {
                    view.becomeFirstResponder()
                } else if canBecomeFirstResponder {
                    becomeFirstResponder()
                } else {
                    assertionFailure()
                }
            } else {
                responder.becomeFirstResponder()
            }
        } else {
            _SwiftUIX_firstResponderController?.resignFirstResponder()
        }
    }
}
#elseif os(macOS)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitViewController {
    public var _SwiftUIX_firstResponderController: AppKitOrUIKitViewController? {
        _SwiftUIX_nearestFirstResponder as? NSViewController
    }
    
    @discardableResult
    public func _SwiftUIX_makeFirstResponder(
        _ responder: AppKitOrUIKitResponder?
    ) -> Bool {
        guard let window = view.window else {
            return false
        }
        
        return window.makeFirstResponder(responder)
    }
}
#endif

