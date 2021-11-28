//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

var _areAnimationsDisabledGlobally: Bool = false

public func _withoutAnimation(_ flag: Bool = true, _ body: () -> ()) {
    guard flag else {
        return body()
    }
    
    var transaction = Transaction(animation: .none)
    
    transaction.disablesAnimations = true
    
    withTransaction(transaction) {
        body()
    }
}

public func _withoutAppKitOrUIKitAnimation(_ flag: Bool = true, _ body: () -> ()) {
    guard flag else {
        return body()
    }
    
    #if os(iOS)
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    body()
    CATransaction.commit()
    #else
    body()
    #endif
}

/// Returns the result of recomputing the view’s body with animations disabled.
public func withoutAnimation(_ flag: Bool = true, _ body: () -> ()) {
    guard flag else {
        return body()
    }
    
    _areAnimationsDisabledGlobally = true
    
    _withoutAnimation {
        body()
    }
    
    _areAnimationsDisabledGlobally = false
}

public func withAnimation(
    _ animation: Animation = .default,
    after delay: DispatchTimeInterval,
    body: @escaping () -> Void
) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        withAnimation(animation) {
            body()
        }
    }
}
