//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Transaction {
    public var isAnimated: Bool {
        guard !disablesAnimations else {
            return false
        }
        
        return true
    }
}
