//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
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
    ) -> Bool {
        if let responder {
            if responder === self {
                if view.canBecomeFirstResponder {
                    return view.becomeFirstResponder()
                } else if canBecomeFirstResponder {
                    return becomeFirstResponder()
                } else {
                    assertionFailure()
                    
                    return false
                }
            } else {
                return responder.becomeFirstResponder()
            }
        } else {
            guard let responder = _SwiftUIX_firstResponderController else {
                return false
            }
            
            return responder.resignFirstResponder()
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

