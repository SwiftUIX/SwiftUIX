//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct FrameReaderProxy {
    /// Data from the preference key `_NamedViewDescription.PreferenceKey`.
    var preferenceData: [AnyHashable: _NamedViewDescription] = [:]
    /// Data sourced from `EnvironmentValues._frameReaderProxy`.
    var environmentSourcedData: [AnyHashable: _NamedViewDescription] = [:]
    
    private func viewDescription(forFrameWithID id: AnyHashable) -> _NamedViewDescription? {
        preferenceData[FrameID(base: id)] ?? environmentSourcedData[FrameID(base: id)]
    }
    
    public func frame(
        for identifier: AnyHashable,
        in coordinateSpace: CoordinateSpace
    ) -> CGRect {
        assert(coordinateSpace == .global, "The only coordinateSpace supported currently is .global")
        
        return viewDescription(forFrameWithID: identifier)?.globalBounds ?? .zero
    }
    
    public func size(
        for identifier: AnyHashable
    ) -> CGSize? {
        viewDescription(forFrameWithID: identifier)?.globalBounds.size
    }
    
    @available(*, deprecated, message: "The returned size is now an `Optional<CGSize>`, not CGSize that defaults to 0 in lieu of a resolved size.")
    @_disfavoredOverload
    public func size(
        for identifier: AnyHashable
    ) -> CGSize {
        viewDescription(forFrameWithID: identifier)?.globalBounds.size ?? .zero
    }
    
    public func intersectionSize(
        between x: AnyHashable,
        and y: AnyHashable
    ) -> CGSize {
        guard let xFrame = viewDescription(forFrameWithID: x)?.globalBounds else {
            return .zero
        }
        
        guard let yFrame = viewDescription(forFrameWithID: y)?.globalBounds else {
            return .zero
        }
        
        return xFrame.intersection(yFrame).size
    }
    
    public func percentageIntersection(
        between x: AnyHashable,
        and y: AnyHashable
    ) -> Double? {
        let intersectionSize = self.intersectionSize(between: x, and: y)
        
        guard let xSize = size(for: x) else {
            return nil
        }
        
        let xSizeArea = xSize.width * xSize.height
        let intersectionSizeArea = intersectionSize.width * intersectionSize.height
        
        if xSizeArea.isZero || intersectionSizeArea.isZero {
            return 0
        }
        
        return Double(intersectionSizeArea / xSizeArea)
    }
}

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

// MARK: - Auxiliary

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

// MARK: - Supplementary

extension View {
    public func frame<ID: Hashable>(id: ID) -> some View {
        modifier(AttachFrameID(frameID: FrameID(base: id)))
    }
}

// MARK: - Helpers

private final class CaptureViewSizePreferenceKey<T: View>: TakeLastPreferenceKey<CGSize> {
    
}

extension View {
    /// Measures and records the size of the view.
    ///
    /// - Parameters:
    ///   - shouldMeasure: A Boolean value that determines if the size measurement should occur. Defaults to `true`.
    ///   - binding: A binding to an optional CGSize to store the measured size.
    /// - Returns: A modified view that measures its size and updates the binding.
    ///
    /// This function uses a GeometryReader to measure the size of the view. When `shouldMeasure` is `true`,
    /// it updates the binding with the current size. The size is set to `nil` when the view disappears.
    @ViewBuilder
    public func _measureAndRecordSize(
        _ shouldMeasure: Bool = true,
        into binding: Binding<CGSize?>
    ) -> some View {
        let binding = binding.removeDuplicates()
        
        self.background {
            if shouldMeasure {
                GeometryReader { proxy in
                    Color.clear
                        .hidden()
                        .accessibility(hidden: true)
                        .onAppear {
                            binding.wrappedValue = proxy.size
                        }
                        .onDisappear {
                            binding.wrappedValue = nil
                        }
                        .onChange(of: proxy.size) { size in
                            binding.wrappedValue = size
                        }
                }
                .allowsHitTesting(false)
                .accessibility(hidden: true)
            }
        }
    }
    
    /// Measures and records the size of the view.
    ///
    /// - Parameters:
    ///   - shouldMeasure: A Boolean value that determines if the size measurement should occur. Defaults to `true`.
    ///   - binding: A non-optional binding to a CGSize to store the measured size.
    /// - Returns: A modified view that measures its size and updates the binding.
    ///
    /// This function is similar to the first, but uses a non-optional CGSize binding.
    /// It internally converts the non-optional binding into an optional binding, providing a default value of `.zero`.
    public func _measureAndRecordSize(
        _ shouldMeasure: Bool = true,
        into binding: Binding<CGSize>
    ) -> some View {
        _measureAndRecordSize(shouldMeasure, into: binding._asOptional(defaultValue: .zero))
    }
    
    /// Measures and records the size of the view using a closure.
    ///
    /// - Parameters:
    ///   - shouldMeasure: A Boolean value that determines if the size measurement should occur. Defaults to `true`.
    ///   - fn: A closure that is called with the new size value.
    /// - Returns: A modified view that measures its size and calls the closure with the new size.
    ///
    /// This variant allows passing a closure that will be called with the new size value.
    /// It internally creates a binding that calls this closure when the size changes.
    public func _measureAndRecordSize(
        _ shouldMeasure: Bool = true,
        _ fn: @escaping (CGSize) -> Void
    ) -> some View {
        _measureAndRecordSize(
            shouldMeasure,
            into: Binding<CGSize>(
                get: { .zero },
                set: { fn($0) }
            )
        )
    }
}
