//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct IntrinsicGeometryProxy {
    public let frame: CGRect?
    
    public var size: CGSize {
        frame?.size ?? .zero
    }
    
    public var estimatedFrame: CGRect {
        frame ?? .zero
    }
}

/// A container view that recursively defines its content as a function of the content's size and coordinate space.
public struct IntrinsicGeometryReader<Content: View>: View {
    private let content: (IntrinsicGeometryProxy) -> Content
    
    public init(@ViewBuilder _ content: @escaping (IntrinsicGeometryProxy) -> Content) {
        self.content = content
    }
    
    @DelayedState var frame: CGRect?
    
    public var body: some View {
        self.content(.init(frame: self.frame)).background(
            GeometryReader { geometry in
                ZeroSizeView().then { _ in
                    self.frame = geometry.frame(in: .local)
                }
            }
        )
    }
}
