//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A proxy for access to the size and coordinate space (for anchor resolution) of the content view.
@_documentation(visibility: internal)
public struct IntrinsicGeometryProxy: Equatable {
    private let localFrame: CGRect?
    private let globalFrame: CGRect?
    private let customCoordinateSpace: CoordinateSpace?
    private let frameInCustomCoordinateSpace: CGRect?
    
    public let safeAreaInsets: EdgeInsets
    
    public var size: CGSize {
        localFrame?.size ?? .zero
    }
    
    public init(
        _ geometry: GeometryProxy?,
        coordinateSpace: CoordinateSpace?
    ) {
        localFrame = geometry?.frame(in: .local)
        globalFrame = geometry?.frame(in: .global)
        customCoordinateSpace = coordinateSpace
        frameInCustomCoordinateSpace = coordinateSpace.flatMap({ geometry?.frame(in: $0) })
        
        safeAreaInsets = geometry?.safeAreaInsets ?? .zero
    }
    
    public func _frame(
        in coordinateSpace: CoordinateSpace
    ) -> CGRect? {
        switch coordinateSpace {
            case .local:
                guard let result = localFrame else {
                    return nil
                }
                
                return result
            case .global:
                guard let result = globalFrame else {
                    return nil
                }
                
                return result
            case .named:
                if coordinateSpace == customCoordinateSpace {
                    return frameInCustomCoordinateSpace ?? .zero
                } else {
                    assertionFailure("CoordinateSpace.named(_:) is currently unsupported in IntrinsicGeometryProxy.")
                    
                    return .init()
                }
            default:
                return nil
        }
    }

    public func frame(
        in coordinateSpace: CoordinateSpace
    ) -> CGRect {
        _frame(in: coordinateSpace) ?? .zero
    }
}

/// A container view that recursively defines its content as a function of the content's size and coordinate space.
@_documentation(visibility: internal)
public struct IntrinsicGeometryReader<Content: View>: View {
    private let coordinateSpace: CoordinateSpace?
    private let content: (IntrinsicGeometryProxy) -> Content
    
    @State private var proxy: IntrinsicGeometryProxy
    
    public init(
        @ViewBuilder _ content: @escaping (IntrinsicGeometryProxy) -> Content
    ) {
        self.coordinateSpace = nil
        self.content = content
        self._proxy = .init(wrappedValue: IntrinsicGeometryProxy(nil, coordinateSpace: nil))
    }

    public init(
        coordinateSpace: CoordinateSpace,
        @ViewBuilder _ content: @escaping (IntrinsicGeometryProxy) -> Content
    ) {
        self.coordinateSpace = coordinateSpace
        self.content = content
        self._proxy = .init(initialValue: IntrinsicGeometryProxy(nil, coordinateSpace: coordinateSpace))
    }
        
    public var body: some View {
        content(proxy).background {
            GeometryReader { geometry in
                let proxy = IntrinsicGeometryProxy(geometry, coordinateSpace: coordinateSpace)

                ZeroSizeView()
                    .onAppear {
                        self.proxy = proxy
                    }
                    .onChange(of: proxy) { newProxy in
                        self.proxy = newProxy
                    }
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
    }
}

@_documentation(visibility: internal)
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
                if geometry?._SwiftUIX_globalFrame != newValue._SwiftUIX_globalFrame {
                    geometry = newValue
                }
            }
        }
    }
}

@_documentation(visibility: internal)
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
