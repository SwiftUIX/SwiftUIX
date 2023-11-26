//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that overlays its children, aligning them in both axes.
///
/// Similar to `ZStack`, but also fills the entire coordinate space of its container view if possible.
public struct XStack<Content: View>: View {
    public let alignment: Alignment
    public let content: Content
    
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }
    
    @inlinable
    public var body: some View {
        ZStack(alignment: alignment) {
            XSpacer()
            
            content
        }
    }
}

extension XStack where Content == EmptyView {
    public init() {
        self.init {
            EmptyView()
        }
    }
}
