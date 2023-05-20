//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitWindow {
    public static var _firstKeyInstance: AppKitOrUIKitWindow? {
        #if os(iOS) || os(macOS)
        return AppKitOrUIKitApplication.shared.firstKeyWindow
        #else
        assertionFailure("unimplemented")
        
        return nil
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
#endif
