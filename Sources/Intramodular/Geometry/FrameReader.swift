//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct FrameReader<Content: View>: View {
    @Namespace var namespace
        
    public let content: (FrameReaderProxy) -> Content
    
    @State private var proxy = FrameReaderProxy()
    
    public init(
        @ViewBuilder content: @escaping (FrameReaderProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(proxy)
            .environment(\._frameReaderProxy, $proxy)
            .onPreferenceChange(_NamedViewDescription.PreferenceKey.self) { value in
                DispatchQueue.asyncOnMainIfNecessary {
                    proxy.preferenceData = value.base
                }
            }
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    struct FrameReaderProxyKey: EnvironmentKey {
        static var defaultValue: Binding<FrameReaderProxy>? = nil
    }
    
    var _frameReaderProxy: Binding<FrameReaderProxy>? {
        get {
            self[FrameReaderProxyKey.self]
        } set {
            self[FrameReaderProxyKey.self] = newValue
        }
    }
}

private struct FrameID: Hashable {
    let base: AnyHashable
    
    init(base: AnyHashable) {
        self.base = base
    }
}

private struct AttachFrameID: ViewModifier {
    @Environment(\._frameReaderProxy) var _frameReaderProxy
    
    let frameID: FrameID
    
    func body(content: Content) -> some View {
        content
            .name(frameID)
            .background {
                GeometryReader { geometry in
                    PerformAction {
                        guard let _frameReaderProxy = _frameReaderProxy else {
                            return
                        }

                        DispatchQueue.asyncOnMainIfNecessary {
                            let description = _NamedViewDescription(
                                name: frameID,
                                id: nil,
                                geometry: geometry
                            )
                            
                            if _frameReaderProxy.wrappedValue.preferenceData[frameID] == nil {
                                _frameReaderProxy.wrappedValue.environmentSourcedData[frameID] = description
                            }
                        }
                    }
                }
            }
    }
}

public struct FrameReaderProxy {
    /// Data from the preference key `_NamedViewDescription.PreferenceKey`.
    var preferenceData: [AnyHashable: _NamedViewDescription] = [:]
    /// Data sourced from `EnvironmentValues._frameReaderProxy`.
    var environmentSourcedData: [AnyHashable: _NamedViewDescription] = [:]

    private func viewDescription(forFrameWithID id: AnyHashable) -> _NamedViewDescription? {
        preferenceData[FrameID(base: id)] ?? environmentSourcedData[FrameID(base: id)]
    }

    public func frame(for identifier: AnyHashable, in coordinateSpace: CoordinateSpace) -> CGRect {
        assert(coordinateSpace == .global, "The only coordinateSpace supported currently is .global")

        return viewDescription(forFrameWithID: identifier)?.globalBounds ?? .zero
    }

    public func size(for identifier: AnyHashable) -> CGSize {
        viewDescription(forFrameWithID: identifier)?.globalBounds.size ?? .zero
    }
    
    public func intersectionSize(between x: AnyHashable, and y: AnyHashable) -> CGSize {
        guard let xFrame = viewDescription(forFrameWithID: x)?.globalBounds else {
            return .zero
        }
        
        guard let yFrame = viewDescription(forFrameWithID: y)?.globalBounds else {
            return .zero
        }
        
        return xFrame.intersection(yFrame).size
    }
    
    public func percentageIntersection(between x: AnyHashable, and y: AnyHashable) -> Double {
        let intersectionSize = self.intersectionSize(between: x, and: y)
        let xSize = size(for: x)
        
        let xSizeArea = xSize.width * xSize.height
        let intersectionSizeArea = intersectionSize.width * intersectionSize.height
        
        if xSizeArea.isZero || intersectionSizeArea.isZero {
            return 0
        }
        
        return Double(intersectionSizeArea / xSizeArea)
    }
}

// MARK: - API -

extension View {
    public func frame<ID: Hashable>(id: ID) -> some View {
        modifier(AttachFrameID(frameID: FrameID(base: id)))
    }
}

// MARK: - Helpers -

private final class CaptureViewSizePreferenceKey<T: View>: TakeLastPreferenceKey<CGSize> {
    
}

extension View {
    public func captureSize(in binding: SetBinding<CGSize>) -> some View {
        overlay {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: CaptureViewSizePreferenceKey<Self>.self,
                    value: proxy.size
                )
            }
        }
        .onPreferenceChange(CaptureViewSizePreferenceKey<Self>.self) { size in
            if let size = size {
                binding.wrappedValue = size
            }
        }
        .preference(key: CaptureViewSizePreferenceKey<Self>.self, value: nil)
    }
    
    public func captureSize(in binding: Binding<CGSize>) -> some View {
        captureSize(in: SetBinding { newValue in
            if binding.wrappedValue != newValue {
                binding.wrappedValue = newValue
            }
        })
    }
}
