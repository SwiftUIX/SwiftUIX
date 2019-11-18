//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift

extension CGSize {
    public var minimumDimensionLength: CGFloat {
        min(width, height)
    }
    
    public var maximumDimensionLength: CGFloat {
        max(width, height)
    }
}
