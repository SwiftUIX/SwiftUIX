//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift
import SwiftUI

extension CGSize {
    public static var infinite: CGSize {
        .init(
            width: CGFloat.infinity,
            height: CGFloat.infinity
        )
    }

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
    
    var isAreaZero: Bool {
        minimumDimensionLength.isZero
    }
    
    var isAreaPracticallyInfinite: Bool {
        maximumDimensionLength == .greatestFiniteMagnitude || maximumDimensionLength == .infinity
    }
    
    var isRegularAndNonZero: Bool {
        guard !isAreaPracticallyInfinite else {
            return false
        }
        
        guard !isAreaZero else {
            return false
        }
        
        return true
    }
    
    public static func _maxByArea(_ lhs: CGSize, rhs: CGSize) -> CGSize {
        guard lhs.isRegularAndNonZero, rhs.isRegularAndNonZero else {
            return lhs
        }
        
        let _lhs = lhs.width * lhs.height
        let _rhs = rhs.width * rhs.height
        
        if _lhs >= _rhs {
            return lhs
        } else {
            return rhs
        }
    }
    
    public static func _maxByCombining(_ lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }
}

extension CGSize {
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
    func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        .init(
            width: width.rounded(rule),
            height: height.rounded(rule)
        )
    }
}

extension CGSize {
    func fits(_ other: Self) -> Bool {
        guard width <= other.width else {
            return false
        }
        
        guard height <= other.height else {
            return false
        }
        
        return true
    }
}
