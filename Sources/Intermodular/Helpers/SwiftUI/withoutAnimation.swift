//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public func withoutAnimation(_ body: () -> ()) {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    CATransaction.begin()
    CATransaction.disableActions()
    #endif
    
    withAnimation(.none) {
        body()
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    CATransaction.commit()
    #endif
}
