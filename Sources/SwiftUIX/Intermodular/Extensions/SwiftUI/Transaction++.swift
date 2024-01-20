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
    
    public mutating func disableAnimations() {
        if animation == nil && disablesAnimations {
            return
        }
        
        animation = nil
        disablesAnimations = true
    }
}

public func _withTransactionIfNotNil<Result>(
    _ transaction: Transaction?,
    body: () throws -> Result
) rethrows -> Result {
    if let transaction {
        return try withTransaction(transaction, body)
    } else {
        return try body()
    }
}
