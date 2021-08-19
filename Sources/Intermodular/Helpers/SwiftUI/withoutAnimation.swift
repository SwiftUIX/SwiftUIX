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
        
    _areAnimationsDisabledGlobally = true
    
    withAnimation(.none) {
        body()
    }
    
    _areAnimationsDisabledGlobally = false
}
