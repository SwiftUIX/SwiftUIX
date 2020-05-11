//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct OptionalDimensions: ExpressibleByNilLiteral, Hashable {
    public let width: CGFloat?
    public let height: CGFloat?
    
    public init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    
    public init(_ size: CGSize) {
        self.init(width: size.width, height: size.height)
    }
    
    public init(nilLiteral: ()) {
        self.init(width: nil, height: nil)
    }
}

// MARK: - Helpers -

extension CGSize {
    public init(_ dimensions: OptionalDimensions, default: CGSize) {
        self.init(width: dimensions.width ?? `default`.width, height: dimensions.height ?? `default`.height)
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
