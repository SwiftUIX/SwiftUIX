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
                
                guard let navigationController = $0.nearestNavigationController else {
                    return
                }
                
                navigationController.splitViewController?.primaryBackgroundStyle = .sidebar
                
                if #available(iOS 14.0, *) {
                    #if !targetEnvironment(macCatalyst)
                    UIView.performWithoutAnimation {
                        navigationController.splitViewController?.show(.primary)
                        navigationController.splitViewController?.hide(.primary)
                    }
                    #endif
                }
                
                isFixed.wrappedValue = true
            }
        }
        #else
        return self
        #endif
    }
}
