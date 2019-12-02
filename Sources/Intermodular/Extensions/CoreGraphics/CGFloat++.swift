//
//  Copyright (c) FamPay
//

import CoreGraphics

extension CGFloat {
    public func pixelsToPoints() -> CGFloat {
        return self / Screen.main.scale
    }
    
    public static func onePixelInPoints() -> CGFloat {
        return Self(1).pixelsToPoints()
    }
}
