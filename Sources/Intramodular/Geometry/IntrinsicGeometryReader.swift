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

public struct _BackgroundGeometryReader<Content: View>: View {
    private struct GeometryPreferenceKey: PreferenceKey {
        typealias Value = _KeyPathEquatable<GeometryProxy, CGSize>?
        
        static var defaultValue: Value {
            nil
        }
        
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue() ?? value
        }
    }
    
    private let content: (GeometryProxy) -> Content
    
    @State private var geometry: GeometryProxy?
    
    public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if let geometry = geometry {
                content(geometry)
            }
        }
        .background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: GeometryPreferenceKey.self,
                    value: _KeyPathEquatable(root: geometry, keyPath: \.size)
                )
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
        .onPreferenceChange(GeometryPreferenceKey.self) { newValue in
            guard let newValue = newValue?.root else {
                return
            }
            
            Task { @MainActor in
                if geometry?._globalFrame != newValue._globalFrame {
                    geometry = newValue
                }
            }
        }
    }
}

public struct _AxesGeometryReader<Content: View>: View {
    private let axes: Axis.Set
    private let content: (IntrinsicGeometryProxy) -> Content
    
    @State private var geometry: GeometryProxy?
    
    public init(
        _ axes: Axis.Set,
        @ViewBuilder content: @escaping (IntrinsicGeometryProxy) -> Content
    ) {
        self.axes = axes
        self.content = content
    }
    
    @_disfavoredOverload
    public init(
        _ axis: Axis,
        @ViewBuilder content: @escaping (IntrinsicGeometryProxy) -> Content
    ) {
        self.init(
            axis == .horizontal ? Axis.Set.horizontal : Axis.Set.vertical,
            content: content
        )
    }
    
    public var body: some View {
        IntrinsicGeometryReader { (proxy: IntrinsicGeometryProxy) in
            content(proxy)
                .frame(
                    maxWidth: axes.contains(.horizontal) ? .infinity : nil,
                    maxHeight: axes.contains(.vertical) ? .infinity : nil
                )
        }
    }
}
