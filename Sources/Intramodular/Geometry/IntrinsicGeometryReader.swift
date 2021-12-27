//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A proxy for access to the size and coordinate space (for anchor resolution) of the content view.
public struct IntrinsicGeometryProxy: Equatable {
    private let localFrame: CGRect?
    private let globalFrame: CGRect?
    
    public let safeAreaInsets: EdgeInsets
    
    public var size: CGSize {
        localFrame?.size ?? .zero
    }
    
    public init(_ geometry: GeometryProxy?) {
        localFrame = geometry?.frame(in: .local)
        globalFrame = geometry?.frame(in: .global)
        safeAreaInsets = geometry?.safeAreaInsets ?? .zero
    }
    
    public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
        switch coordinateSpace {
            case .local:
                return localFrame ?? .init()
            case .global:
                return globalFrame ?? .init()
            case .named:
                assertionFailure("CoordinateSpace.named(_:) is currently unsupported in IntrinsicGeometryProxy.")
                
                return .init()
            default:
                return .init()
        }
    }
}

/// A container view that recursively defines its content as a function of the content's size and coordinate space.
public struct IntrinsicGeometryReader<Content: View>: View {
    private let content: (IntrinsicGeometryProxy) -> Content
    
    @State private var proxy = IntrinsicGeometryProxy(nil)

    public init(@ViewBuilder _ content: @escaping (IntrinsicGeometryProxy) -> Content) {
        self.content = content
    }
        
    public var body: some View {
        content(proxy).background {
            GeometryReader { geometry in
                PerformAction {
                    let proxy = IntrinsicGeometryProxy(geometry)
                    
                    if self.proxy != proxy {
                        self.proxy = proxy
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
    }
}
