//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    /// Set the background color of the presented sheet.
    ///
    /// This implementation relies on the assumpion that a SwiftUI sheet is backed by a `UIViewController` or an `NSViewController`.
    /// Use `Color.clear` if you wish to set the underlying view controller's `view.backgroundColor` to `nil`.
    public func sheetBackground(_ color: Color) -> some View {
        withInlineState(initialValue: false) { isSet in
            onAppKitOrUIKitViewControllerResolution { viewController in
                guard !isSet.wrappedValue else {
                    return
                }
                
                defer {
                    isSet.wrappedValue = true
                }
                
                #if os(iOS) || os(tvOS)
                if color == .clear {
                    (viewController.root ?? viewController).view.backgroundColor = nil
                } else {
                    (viewController.root ?? viewController).view.backgroundColor = color.toUIColor()
                }
                #else
                if #available(macOS 11, *) {
                    viewController.view.wantsLayer = true
                    viewController.view.layer?.backgroundColor = color.cgColor
                }
                #endif
            }
        }
        .modifier(_ResolveAppKitOrUIKitViewController())
    }
    #endif
}
