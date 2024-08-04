//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

extension AppKitOrUIKitApplication {
    public var _SwiftUIX_noRegularWindowDisplaying: Bool {
        AppKitOrUIKitWindow._SwiftUIX_allInstances.filter({ $0._SwiftUIX_isInRegularDisplay }).isEmpty
    }
}

#if os(macOS)
extension AppKitOrUIKitApplication {
    public func _SwiftUIX_closeAllWindows() {
        for window in AppKitOrUIKitWindow._SwiftUIX_allInstances {
            guard window._SwiftUIX_isInRegularDisplay else {
                continue
            }
            
            window.resignMain()
            window.close()
        }
    }
    
    public func _SwiftUIX_orderFront() {        
        Task.detached { @MainActor in
            if let window = AppKitOrUIKitWindow._SwiftUIX_allInstances.first(where: { $0._SwiftUIX_isInRegularDisplay }) {
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                window.becomeKey()
            }
        }
    }
}
#endif

#endif
