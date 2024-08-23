//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _CustomOptionalDimensionsConvertible {
    func _toOptionalDimensions() -> OptionalDimensions
}

@_frozen
@_documentation(visibility: internal)
public struct OptionalDimensions: ExpressibleByNilLiteral, Hashable {
    public static var greatestFiniteDimensions: OptionalDimensions {
        .init(width: .greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
    }
    
    public static var infinite: OptionalDimensions {
        .init(width: .infinity, height: .infinity)
    }

    public var width: CGFloat?
    public var height: CGFloat?
    
    public init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    
    public init<T: _CustomOptionalDimensionsConvertible>(_ size: T) {
        self = size._toOptionalDimensions()
    }
    
    public init<T: _CustomOptionalDimensionsConvertible>(_ size: T?) {
        if let size = size {
            self.init(size)
        } else {
            self.init(nilLiteral: ())
        }
    }

    public init(nilLiteral: ()) {
        self.init(width: nil, height: nil)
    }
        
    public init() {
        
    }
    
    public subscript(_ dimensions: Set<FrameDimensionType>) -> Self {
        Self(
            width: dimensions.contains(.width) ? self.width : nil,
            height: dimensions.contains(.height) ? self.height : nil
        )
    }
}

extension OptionalDimensions {
    public var specifiedDimensionsAreNonZero: Bool {
        var result = true
        
        if let width {
            result = result && (width != 0)
        }
        
        if let height {
            result = result && (height != 0)
        }
        
        return result
    }
}

// MARK: - Extensions

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
extension OptionalDimensions {
    public init(
        normalNonZeroDimensionsFrom size: CGSize
    ) {
        self.init(
            width: (size.width.isNormal && !size.width.isZero) ? size.width : nil,
            height: (size.height.isNormal && !size.height.isZero) ? size.height : nil
        )
    }
    
    public init(
        intrinsicContentSize: CGSize
    ) {
        self.init(
            width: (intrinsicContentSize.width == AppKitOrUIKitView.noIntrinsicMetric || intrinsicContentSize.width == CGFloat.greatestFiniteMagnitude) ? nil : intrinsicContentSize.width,
            height: (intrinsicContentSize.height == AppKitOrUIKitView.noIntrinsicMetric || intrinsicContentSize.height == CGFloat.greatestFiniteMagnitude) ? nil : intrinsicContentSize.height
        )
    }
    
    public func toAppKitOrUIKitIntrinsicContentSize() -> CGSize {
        CGSize(
            width: width ?? AppKitOrUIKitView.noIntrinsicMetric,
            height: height ?? AppKitOrUIKitView.noIntrinsicMetric
        )
    }
}
#endif

extension OptionalDimensions {
    public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        .init(
            width: width?.rounded(rule),
            height: height?.rounded(rule)
        )
    }

    public mutating func clamp(to dimensions: OptionalDimensions) {
        if let maxWidth = dimensions.width {
            if let width = self.width {
                self.width = min(width, maxWidth)
            } else {
                self.width = maxWidth
            }
        }
        
        if let maxHeight = dimensions.height {
            if let height = self.height {
                self.height = min(height, maxHeight)
            } else {
                self.height = maxHeight
            }
        }
    }
    
    public func clamped(to dimensions: OptionalDimensions?) -> Self {
        guard let dimensions = dimensions else {
            return self
        }

        var result = self
        
        result.clamp(to: dimensions)
        
        return result
    }
    
    public func drop(_ axes: Axis.Set) -> Self {
        Self.init(
            width: axes.contains(.horizontal) ? nil : 0,
            height: axes.contains(.vertical) ? nil : 0
        )
    }
}

// MARK: - API

extension View {
    /// Sets the preferred maximum layout width for the view.
    public func preferredMaximumLayoutWidth(
        _ preferredMaximumLayoutWidth: CGFloat?
    ) -> some View {
        environment(\.preferredMaximumLayoutWidth, preferredMaximumLayoutWidth)
    }
    
    /// Sets the preferred maximum layout height for the view.
    public func preferredMaximumLayoutHeight(
        _ preferredMaximumLayoutHeight: CGFloat?
    ) -> some View {
        environment(\.preferredMaximumLayoutHeight, preferredMaximumLayoutHeight)
    }
    
    /// Sets the preferred maximum layout dimensions for the view.
    public func preferredMaximumLayoutDimensions(
        _ size: OptionalDimensions
    ) -> some View {
        environment(\.preferredMaximumLayoutDimensions, size)
    }
    
    /// Sets the preferred maximum layout dimensions for the view.
    public func preferredMaximumLayoutDimensions(
        _ size: CGSize
    ) -> some View {
        preferredMaximumLayoutDimensions(.init(size))
    }
    
    public func frame(
        min dimensions: OptionalDimensions
    ) -> some View {
        frame(
            minWidth: dimensions.width,
            minHeight: dimensions.height
        )
    }
    
    public func frame(
        _ dimensions: OptionalDimensions
    ) -> some View {
        frame(
            width: dimensions.width,
            height: dimensions.height
        )
    }

    public func frame(
        max dimensions: OptionalDimensions
    ) -> some View {
        frame(
            minWidth: dimensions.width,
            minHeight: dimensions.height
        )
    }
}

// MARK: - Auxiliary

extension CGSize: _CustomOptionalDimensionsConvertible {
    public func _toOptionalDimensions() -> OptionalDimensions {
        .init(width: width, height: height)
    }
}

extension OptionalDimensions: _CustomOptionalDimensionsConvertible {
    public func _toOptionalDimensions() -> OptionalDimensions {
        self
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ProposedViewSize: _CustomOptionalDimensionsConvertible {
    public func _toOptionalDimensions() -> OptionalDimensions {
        .init(width: width, height: height)
    }
}

extension EnvironmentValues {
    private final class PreferredMaximumLayoutWidth: DefaultEnvironmentKey<CGFloat> {
        
    }
    
    /// The preferred maximum layout width for the view with this environment.
    ///
    /// The default value is nil.
    public var preferredMaximumLayoutWidth: CGFloat? {
        get {
            self[PreferredMaximumLayoutWidth.self]
        } set {
            self[PreferredMaximumLayoutWidth.self] = newValue
        }
    }
    
    private final class PreferredMaximumLayoutHeight: DefaultEnvironmentKey<CGFloat> {
        
    }
    
    /// The preferred maximum layout height for the view with this environment.
    ///
    /// The default value is nil.
    public var preferredMaximumLayoutHeight: CGFloat? {
        get {
            self[PreferredMaximumLayoutHeight.self]
        } set {
            self[PreferredMaximumLayoutHeight.self] = newValue
        }
    }
    
    /// The preferred maximum layout dimensions for the view with this environment.
    ///
    /// The default value is nil.
    public var preferredMaximumLayoutDimensions: OptionalDimensions {
        get {
            .init(width: preferredMaximumLayoutWidth, height: preferredMaximumLayoutHeight)
        } set {
            preferredMaximumLayoutWidth = newValue.width
            preferredMaximumLayoutHeight = newValue.height
        }
    }
}

extension CGSize {
    public init(_ dimensions: OptionalDimensions, default: CGSize) {
        self.init(
            width: dimensions.width ?? `default`.width,
            height: dimensions.height ?? `default`.height
        )
    }
    
    public init?(_ dimensions: OptionalDimensions) {
        guard let width = dimensions.width, let height = dimensions.height else {
            return nil
        }
        
        self.init(
            width: width,
            height: height
        )
    }
    
    public mutating func clamp(to dimensions: OptionalDimensions) {
        if let maxWidth = dimensions.width {
            width = min(width, maxWidth)
        }
        
        if let maxHeight = dimensions.height {
            height = min(height, maxHeight)
        }
    }
    
    public func clamped(to dimensions: OptionalDimensions) -> Self {
        var result = self
        
        result.clamp(to: dimensions)
        
        return result
    }
    
    public func clamped(to dimensions: CGSize?) -> Self {
        clamped(to: OptionalDimensions(dimensions))
    }
}
