//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Transaction {
    public var isAnimated: Bool {
        if _areAnimationsDisabledGlobally {
            return false
        } else if disablesAnimations {
            return false
        } else {
            return true
        }
    }
}
