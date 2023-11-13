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
        max(min(width, height), 0)
    }
    
    public var maximumDimensionLength: CGFloat {
        max(width, height)
    }
}

extension CGSize {
    @_spi(Internal)
    public var _isNormal: Bool {
        width.isNormal && height.isNormal && (width != .greatestFiniteMagnitude) && (height != .greatestFiniteMagnitude)
    }
        
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
    
    @_spi(Internal)
    public func _isNearlyEqual(
        to size: CGSize,
        threshold: CGFloat
    ) -> Bool {
        return abs(self.width - size.width) < threshold && abs(self.height - size.height) < threshold
    }
}

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

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension CGSize {
    /// Whether the size contains a `AppKitOrUIKitView.noIntrinsicMetric` or an infinity.
    public var _hasUnspecifiedIntrinsicContentSizeDimensions: Bool {
        if width._isInvalidForIntrinsicContentSize || height._isInvalidForIntrinsicContentSize {
            return true
        }
        
        return false
    }
    
    func toAppKitOrUIKitIntrinsicContentSize() -> CGSize {
        var result = self
        
        if result.width._isInvalidForIntrinsicContentSize {
            result.width = AppKitOrUIKitView.noIntrinsicMetric
        }
        
        if result.height._isInvalidForIntrinsicContentSize {
            result.height = AppKitOrUIKitView.noIntrinsicMetric
        }
        
        return result
    }
}

extension CGSize {
    func _hasPlaceholderDimensions(
        for type: _AppKitOrUIKitPlaceholderDimensionType
    ) -> Bool {
        width.isPlaceholderDimension(for: type) || height.isPlaceholderDimension(for: type)
    }
    
    func _hasPlaceholderDimension(
        _ dimension: FrameDimensionType,
        for type: _AppKitOrUIKitPlaceholderDimensionType
    ) -> Bool {
        switch dimension {
            case .width:
                return width.isPlaceholderDimension(for: type)
            case .height:
                return height.isPlaceholderDimension(for: type)
        }
    }
    
    func _filterDimensions(
        _ predicate: (CGFloat) -> Bool
    ) -> OptionalDimensions {
        var result = OptionalDimensions()
        
        if predicate(width) {
            result.width = width
        }
        
        if predicate(height) {
            result.height = height
        }
        
        return result
    }
    
    func _filterPlaceholderDimensions(
        for type: _AppKitOrUIKitPlaceholderDimensionType
    ) -> OptionalDimensions {
        _filterDimensions {
            !$0.isPlaceholderDimension(for: type)
        }
    }
}
#endif

// MARK: - Auxiliary

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
enum _AppKitOrUIKitPlaceholderDimensionType {
    case intrinsicContentSize
    case textContainer
}

extension CGFloat {
    fileprivate var _isInvalidForIntrinsicContentSize: Bool {
        guard isNormal else {
            return true
        }
        
        switch self {
            case AppKitOrUIKitView.noIntrinsicMetric:
                return false
            case CGFloat.greatestFiniteMagnitude:
                return true
            case CGFloat.infinity:
                return true
            case 10000000.0:
                return true
            default:
                return false
        }
    }
    
    func isPlaceholderDimension(for type: _AppKitOrUIKitPlaceholderDimensionType) -> Bool {
        switch type {
            case .intrinsicContentSize:
                return self == AppKitOrUIKitView.noIntrinsicMetric
            case .textContainer:
                return self == 10000000.0 || self == CGFloat.greatestFiniteMagnitude
        }
    }
}
#endif
