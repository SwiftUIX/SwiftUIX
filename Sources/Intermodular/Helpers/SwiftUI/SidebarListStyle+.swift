//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Fixes the weird gray background for SidebarListStyle() on Mac Catalyst.
    public func _fixSidebarListStyle() -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return withInlineState(initialValue: false) { isFixed in
            self.onAppKitOrUIKitViewControllerResolution {
                guard !isFixed.wrappedValue else {
                    return
                }
                
                $0.navigationController?.nearestResponder(ofKind: UISplitViewController.self)?.primaryBackgroundStyle = .sidebar
                
                isFixed.wrappedValue = true
            }
        }
        #else
        return self
        #endif
    }
}
