//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A view for presenting a stack of views.
/// Like `NavigationView`, but for modal presentation.
public struct PresentationView<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        #if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)
        content.modifier(_ResolveAppKitOrUIKitViewController())
        #else
        content
        #endif
    }
}
