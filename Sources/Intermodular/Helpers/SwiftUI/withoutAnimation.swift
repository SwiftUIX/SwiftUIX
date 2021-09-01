//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

var _areAnimationsDisabledGlobally: Bool = false

func _withoutAnimation(_ flag: Bool = true, _ body: () -> ()) {
    guard flag else {
        return body()
    }
    
    withAnimation(.none) {
        body()
    }
}

/// Returns the result of recomputing the view’s body with animations disabled.
public func withoutAnimation(_ flag: Bool = true, _ body: () -> ()) {
    guard flag else {
        return body()
    }
    
    _areAnimationsDisabledGlobally = true
    
    withAnimation(.none) {
        body()
    }
    
    _areAnimationsDisabledGlobally = false
}
