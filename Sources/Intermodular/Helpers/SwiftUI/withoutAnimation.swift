//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

var _areAnimationsDisabledGlobally: Bool = false

public func withoutAnimation(_ flag: Bool = true, _ body: () -> ()) {
    guard flag else {
        return body()
    }
    
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    CATransaction.begin()
    CATransaction.disableActions()
    #endif
    
    _areAnimationsDisabledGlobally = true
    
    withAnimation(.none) {
        body()
    }
    
    _areAnimationsDisabledGlobally = false
    
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    CATransaction.commit()
    #endif
}
