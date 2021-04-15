//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public func withoutAnimation(_ body: () -> ()) {
    CATransaction.begin()
    CATransaction.disableActions()
    
    withAnimation(.none) {
        body()
    }
    
    CATransaction.commit()
}
