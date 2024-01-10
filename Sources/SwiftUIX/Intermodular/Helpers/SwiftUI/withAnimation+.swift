//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@usableFromInline
var _areAnimationsDisabledGlobally: Bool = false

@_transparent
public func _withoutAnimation<T>(
    _ flag: Bool = true,
    _ body: () -> T
) -> T {
    guard flag else {
        return body()
    }
    
    var transaction = Transaction(animation: .none)
    
    transaction.disablesAnimations = true
    
    return withTransaction(transaction) {
        body()
    }
}

@usableFromInline
var _SwiftUIX_AppKitOrUIKitAnimationIsDisabled: Bool = false

@_transparent
public func _withoutAppKitOrUIKitAnimation<Result>(
    _ flag: Bool = true,
    _ body: () -> Result
) -> Result {
    guard flag else {
        return body()
    }
    
    guard !_SwiftUIX_AppKitOrUIKitAnimationIsDisabled else {
        return body()
    }
    
    _SwiftUIX_AppKitOrUIKitAnimationIsDisabled = true
    
    var result: Result!
        
    #if os(iOS)
    UIView.performWithoutAnimation {
        result = body()
    }
    #elseif os(macOS)
    NSAnimationContext.beginGrouping()
    NSAnimationContext.current.duration = 0
    NSAnimationContext.current.timingFunction = nil
    result = body()
    NSAnimationContext.endGrouping()
    #else
    result = body()
    #endif
    
    _SwiftUIX_AppKitOrUIKitAnimationIsDisabled = false
    
    return result
}

#if canImport(QuartzCore)
extension CATransaction {
    @usableFromInline
    static var _SwiftUIX_actionsAreDisabled: Bool = false
    
    @_transparent
    @MainActor
    public static func _withDisabledActions<T>(
        _ flag: Bool = true,
        @_implicitSelfCapture _ body: () throws -> T
    ) rethrows -> T {
        guard flag else {
            return try body()
        }

        guard !_SwiftUIX_actionsAreDisabled else {
            return try body()
        }
        
        _SwiftUIX_actionsAreDisabled = true
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
                
        do {
            let result = try body()
            
            CATransaction.commit()

            _SwiftUIX_actionsAreDisabled = false
            
            return result
        } catch {
            CATransaction.commit()
            
            _SwiftUIX_actionsAreDisabled = false
            
            throw error
        }
    }
}
#endif

/// Returns the result of recomputing the view’s body with animations disabled.
@_transparent
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
