//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension View {
    /// Set the background color of the presented sheet.
    ///
    /// This implementation relies on the assumpion that a SwiftUI sheet is backed by a `UIViewController` or an `NSViewController`.
    /// Use `Color.clear` if you wish to set the underlying view controller's `view.backgroundColor` to `nil`.
    public func sheetBackground(_ color: Color) -> some View {
        modifier(_UpdateSheetBackground(color: color))
    }
}

// MARK: - Auxiliary Implementation -

struct _UpdateSheetBackground: ViewModifier {
    let color: Color
    
    @State private var didSet: Bool = false
    
    func body(content: Content) -> some View {
        content.onAppKitOrUIKitViewControllerResolution { viewController in
            guard !didSet else {
                return
            }
            
            defer {
                didSet = true
            }
            
            #if os(iOS) || os(tvOS)
            let newBackgroundColor = color == .clear ? color.toUIColor() : nil
            
            (viewController.root ?? viewController).view.backgroundColor = newBackgroundColor
            #else
            if #available(macOS 11, *) {
                viewController.view.wantsLayer = true
                viewController.view.layer?.backgroundColor = color.cgColor
            }
            #endif
        }
    }
}

#endif
