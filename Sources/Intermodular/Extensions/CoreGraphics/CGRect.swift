//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift

extension CGRect {
    public var minimumDimensionLength: CGFloat {
        min(width, height)
    }
}
