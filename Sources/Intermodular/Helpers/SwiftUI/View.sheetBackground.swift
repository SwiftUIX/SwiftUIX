//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    /// Set the background color of the presented sheet.
    ///
    /// This implementation relies on the assumpion that a SwiftUI sheet is backed by a `UIViewController`.
    public func sheetBackground(_ color: Color) -> some View {
        withInlineState(initialValue: false) { isSet in
            onAppKitOrUIKitViewControllerResolution { viewController in
                guard !isSet.wrappedValue else {
                    return
                }
                
                defer {
                    isSet.wrappedValue = true
                }
                
                if color == .clear {
                    (viewController.root ?? viewController).view.backgroundColor = nil
                } else {
                    (viewController.root ?? viewController).view.backgroundColor = color.toUIColor()
                }
            }
        }
    }
    #endif
}
