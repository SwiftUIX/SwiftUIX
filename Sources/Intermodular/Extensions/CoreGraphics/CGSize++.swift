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
}

extension CGSize {
    @_spi(Internal)
    public var isAreaZero: Bool {
        minimumDimensionLength.isZero
    }
    
    @_spi(Internal)
    public var isAreaPracticallyInfinite: Bool {
        maximumDimensionLength == .greatestFiniteMagnitude || maximumDimensionLength == .infinity
    }
    
    @_spi(Internal)
    public var isRegularAndNonZero: Bool {
        guard !isAreaPracticallyInfinite else {
            return false
        }
        
        guard !isAreaZero else {
            return false
        }
        
        return true
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension CGSize {
    /// Whether the size contains a `AppKitOrUIKitView.noIntrinsicMetric` or an infinity.
    public var _hasUnspecifiedIntrinsicContentSizeDimensions: Bool {
        guard width >= 0 && height >= 0 else {
            return true
        }
        
        switch width {
            case AppKitOrUIKitView.noIntrinsicMetric:
                return true
            case CGFloat.greatestFiniteMagnitude:
                return true
            case CGFloat.infinity:
                return true
            default:
                break
        }
        
        switch height {
            case AppKitOrUIKitView.noIntrinsicMetric:
                return true
            case CGFloat.greatestFiniteMagnitude:
                return true
            case CGFloat.infinity:
                return true
            default:
                break
        }

        return false
    }
}
#endif

extension CGSize {
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
    
    public static func _maxByCombining(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
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
