//
//  Copyright (c) FamPay
//

import CoreGraphics

#if (os(iOS) && canImport(CoreTelephony)) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
extension CGFloat {
    public func pixelsToPoints() -> CGFloat {
        return self / Screen.main.scale
    }
    
    public static func onePixelInPoints() -> CGFloat {
        return Self(1).pixelsToPoints()
    }
}
#endif

@_transparent
func min(_ lhs: Double, _ rhs: CGFloat?) -> Double {
    guard let rhs = rhs else {
        return lhs
    }
    
    return Swift.min(lhs, rhs)
}

@_transparent
func max(_ lhs: Double, _ rhs: CGFloat?) -> Double {
    guard let rhs = rhs else {
        return lhs
    }
    
    return Swift.max(lhs, rhs)
}

extension CGFloat {
    func isApproximatelyEqual(
        to other: CGFloat,
        withThreshold threshold: CGFloat
    ) -> Bool {
        let difference = abs(self - other)
        
        return difference <= threshold
    }
}

extension CGPoint {
    func isApproximatelyEqual(
        to other: CGPoint,
        withThreshold threshold: CGFloat
    ) -> Bool {
        x.isApproximatelyEqual(to: other.x, withThreshold: threshold) && y.isApproximatelyEqual(to: other.y, withThreshold: threshold)
    }
}
