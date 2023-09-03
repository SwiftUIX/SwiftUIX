//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

var _areAnimationsDisabledGlobally: Bool = false

public func _withoutAnimation<T>(_ flag: Bool = true, _ body: () -> T) -> T {
    guard flag else {
        return body()
    }

    var transaction = Transaction(animation: .none)

    transaction.disablesAnimations = true

    return withTransaction(transaction) {
        body()
    }
}

public func _withoutAppKitOrUIKitAnimation(_ flag: Bool = true, _ body: () -> ()) {
    guard flag else {
        return body()
    }
    
    #if os(iOS)
    UIView.performWithoutAnimation {
        body()
    }
    #else
    body()
    #endif
}

/// Returns the result of recomputing the view’s body with animations disabled.
public func withoutAnimation(
    _ flag: Bool = true,
    after delay: DispatchTimeInterval? = nil,
    _ body: @escaping () -> ()
) {
    func _perform() {
        guard flag else {
            return body()
        }
        
        _areAnimationsDisabledGlobally = true
        
        _withoutAnimation {
            body()
        }
        
        _areAnimationsDisabledGlobally = false
    }
    
    if let delay = delay {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            _perform()
        }
    } else {
        _perform()
    }
}

public func withAnimation(
    _ animation: Animation? = .default,
    after delay: DispatchTimeInterval?,
    body: @escaping () -> Void
) {
    if let delay = delay {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let animation {
                withAnimation(animation) {
                    body()
                }
            } else {
                body()
            }
        }
    } else {
        withAnimation(animation) {
            body()
        }
    }
}
