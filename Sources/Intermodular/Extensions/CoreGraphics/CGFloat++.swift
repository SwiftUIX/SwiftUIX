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
