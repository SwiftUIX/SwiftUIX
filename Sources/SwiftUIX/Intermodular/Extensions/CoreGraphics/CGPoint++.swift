//
//  Copyright (c) FamPay
//

import CoreGraphics
import Darwin

extension CGPoint {
    var ceil: CGPoint {
        .init(x: Darwin.ceil(x), y: Darwin.ceil(y))
    }
}
