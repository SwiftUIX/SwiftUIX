//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct Frame: Hashable {
    public enum Dimension: Hashable {
        case constant(CGFloat)
        case relative(CGFloat)
    }
    
    public let width: Dimension?
    public let height: Dimension?
}

// MARK: - Auxiliary Implementation -

extension Frame.Dimension {
    public var isRelative: Bool {
        switch self {
            case .constant:
                return false
            case .relative:
                return true
        }
    }
    
    public func evaluate(in size: CGSize, for axis: Axis) -> CGFloat {
        switch self {
            case .constant(let value):
                return value
            
            case .relative:
                return size.dimensionLength(for: axis)
        }
    }
}

extension Frame {
    public var isRelative: Bool {
        (width?.isRelative ?? true) && (height?.isRelative ?? true)
    }
    
    public func evaluate(in size: CGSize) -> CGSize {
        .init(
            width: width?.evaluate(in: size, for: .horizontal) ?? .infinity,
            height: height?.evaluate(in: size, for: .vertical) ?? .infinity
        )
    }
}
