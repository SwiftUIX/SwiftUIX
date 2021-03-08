//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct OptionalDimensions: ExpressibleByNilLiteral, Hashable {
    public var width: CGFloat?
    public var height: CGFloat?
    
    public init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    
    public init(_ size: CGSize) {
        self.init(width: size.width, height: size.height)
    }
    
    public init(_ size: CGSize?) {
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
}

extension OptionalDimensions {
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
    
    public func clamping(to dimensions: OptionalDimensions) -> Self {
        var result = self
        
        result.clamp(to: dimensions)
        
        return result
    }
}

// MARK: - API -

extension View {
    /// Sets the preferred maximum layout width for the view.
    public func preferredMaximumLayoutWidth(_ preferredMaximumLayoutWidth: CGFloat) -> some View {
        environment(\.preferredMaximumLayoutWidth, preferredMaximumLayoutWidth)
    }
    
    /// Sets the preferred maximum layout height for the view.
    public func preferredMaximumLayoutHeight(_ preferredMaximumLayoutHeight: CGFloat) -> some View {
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
            self[PreferredMaximumLayoutWidth]
        } set {
            self[PreferredMaximumLayoutWidth] = newValue
        }
    }
    
    private final class PreferredMaximumLayoutHeight: DefaultEnvironmentKey<CGFloat> {
        
    }
    
    /// The preferred maximum layout height for the view with this environment.
    ///
    /// The default value is nil.
    public var preferredMaximumLayoutHeight: CGFloat? {
        get {
            self[PreferredMaximumLayoutHeight]
        } set {
            self[PreferredMaximumLayoutHeight] = newValue
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
    
    public mutating func clamp(to dimensions: OptionalDimensions) {
        if let maxWidth = dimensions.width {
            width = min(width, maxWidth)
        }
        
        if let maxHeight = dimensions.height {
            height = min(height, maxHeight)
        }
    }
    
    public func clamping(to dimensions: OptionalDimensions) -> Self {
        var result = self
        
        result.clamp(to: dimensions)
        
        return result
    }
}
