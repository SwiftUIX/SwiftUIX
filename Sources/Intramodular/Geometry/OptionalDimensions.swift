//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_frozen
public struct OptionalDimensions: ExpressibleByNilLiteral, Hashable {
    public var width: CGFloat?
    public var height: CGFloat?
    
    @inlinable
    public init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    
    @inlinable
    public init(_ size: CGSize) {
        self.init(width: size.width, height: size.height)
    }
    
    @inlinable
    public init(_ size: CGSize?) {
        if let size = size {
            self.init(size)
        } else {
            self.init(nilLiteral: ())
        }
    }
    
    @inlinable
    public init(nilLiteral: ()) {
        self.init(width: nil, height: nil)
    }
    
    @inlinable
    public init() {
        
    }
}

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

// MARK: - API -

extension View {
    /// Sets the preferred maximum layout width for the view.
    public func preferredMaximumLayoutWidth(_ preferredMaximumLayoutWidth: CGFloat?) -> some View {
        environment(\.preferredMaximumLayoutWidth, preferredMaximumLayoutWidth)
    }
    
    /// Sets the preferred maximum layout height for the view.
    public func preferredMaximumLayoutHeight(_ preferredMaximumLayoutHeight: CGFloat?) -> some View {
        environment(\.preferredMaximumLayoutHeight, preferredMaximumLayoutHeight)
    }
    
    /// Sets the preferred maximum layout dimensions for the view.
    public func preferredMaximumLayoutDimensions(_ size: OptionalDimensions) -> some View {
        environment(\.preferredMaximumLayoutDimensions, size)
    }
    
    /// Sets the preferred maximum layout dimensions for the view.
    public func preferredMaximumLayoutDimensions(_ size: CGSize) -> some View {
        preferredMaximumLayoutDimensions(.init(size))
    }
    
    public func frame(_ dimensions: OptionalDimensions) -> some View {
        frame(width: dimensions.width, height: dimensions.height)
    }
}

// MARK: - Auxiliary Implementation -

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

// MARK: - Helpers -

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
    
    public mutating func clamp(to dimensions: OptionalDimensions?) {
        if let maxWidth = dimensions?.width {
            width = min(width, maxWidth)
        }
        
        if let maxHeight = dimensions?.height {
            height = min(height, maxHeight)
        }
    }
    
    public func clamped(to dimensions: OptionalDimensions?) -> Self {
        var result = self
        
        result.clamp(to: dimensions)
        
        return result
    }
}
