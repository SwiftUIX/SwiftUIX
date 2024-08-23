//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that overlays its children, aligning them in both axes.
///
/// Similar to `ZStack`, but also fills the entire coordinate space of its container view if possible.
@_documentation(visibility: internal)
public struct XStack<Content: View>: View {
    public let alignment: Alignment
    public let content: Content
        
    @inlinable
    public var body: some View {
        ZStack(alignment: alignment) {
            XSpacer()
            
            content
        }
    }
    
    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }
    
    public init() where Content == ZeroSizeView {
        self.init {
            ZeroSizeView()
        }
    }
}

@_documentation(visibility: internal)
public struct _DeferredXStack<Content: View>: View {
    public let alignment: Alignment
    public let content: Content
    
    @inlinable
    public var body: some View {
        XStack {
            ZeroSizeView()
            
            _VariadicViewAdapter(content) { content in
                _ForEachSubview(content) { subview in
                    _DeferredView {
                        subview
                    }
                }
            }
        }
    }
    
    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }
    
    public init() where Content == ZeroSizeView {
        self.init {
            ZeroSizeView()
        }
    }
}
