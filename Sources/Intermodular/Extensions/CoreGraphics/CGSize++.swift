//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift
import SwiftUI

extension CGSize {
    public static var greatestFiniteSize: CGSize {
        .init(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
    }
    
    public var minimumDimensionLength: CGFloat {
        min(width, height)
    }
    
    public var maximumDimensionLength: CGFloat {
        max(width, height)
    }
    
    public func dimensionLength(for axis: Axis) -> CGFloat {
        switch axis {
            case .horizontal:
                return width
            case .vertical:
                return height
        }
    }
    
    public func anchorPoint(for alignment: Alignment) {
        var result: CGPoint = .zero
        
        switch alignment.horizontal {
            case .leading:
                result.x = 0
            case .center:
                result.x = width / 2
            case .trailing:
                result.x = width
            default:
                break
        }
        
        switch alignment.vertical {
            case .top:
                result.y = 0
            case .center:
                result.y = height / 2
            case .bottom:
                result.y = height
            default:
                break
        }
    }
}

extension CGSize {
    public static func * (lhs: Self, rhs: CGFloat) -> Self {
        .init(
            width: lhs.width * rhs,
            height: lhs.height * rhs
        )
    }
    
    public static func *= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
    public static func / (lhs: Self, rhs: CGFloat) -> Self {
        .init(
            width: lhs.width / rhs,
            height: lhs.height / rhs
        )
    }
    
    public static func /= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs / rhs
    }
}
