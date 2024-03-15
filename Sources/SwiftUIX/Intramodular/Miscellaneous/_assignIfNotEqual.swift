//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@_spi(Internal)
@_optimize(speed)
@_transparent
public func _assignIfNotEqual<Value: Equatable>(
    _ value: Value,
    to destination: inout Value
) {
    if value != destination {
        destination = value
    }
}

extension NSObjectProtocol {
    @_spi(Internal)
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) -> Bool {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
    
    @_spi(Internal)
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value?,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) -> Bool {
        guard let newValue else {
            return false
        }
        
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }

    @_spi(Internal)
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value?>
    ) -> Bool {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
}

extension ObservableObject {
    @_spi(Internal)
    @_disfavoredOverload
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) -> Bool {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
    
    @_spi(Internal)
    @_disfavoredOverload
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value?,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) -> Bool {
        guard let newValue else {
            return false
        }
        
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
    
    @_spi(Internal)
    @_disfavoredOverload
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value?>
    ) -> Bool {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
}

extension NSObjectProtocol where Self: ObservableObject {
    @_spi(Internal)
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) -> Bool {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
    
    @_spi(Internal)
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value?,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) -> Bool {
        guard let newValue else {
            return false
        }
        
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
    
    @_spi(Internal)
    @_optimize(speed)
    @_transparent
    @discardableResult
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value?>
    ) -> Bool {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
            
            return true
        } else {
            return false
        }
    }
}
    
@_spi(Internal)
@_disfavoredOverload
@_optimize(speed)
@_transparent
public func _assignIfNotEqual<Value: AnyObject>(
    _ value: Value,
    to destination: inout Value
) {
    if value !== destination {
        destination = value
    }
}

@_spi(Internal)
@_disfavoredOverload
@_optimize(speed)
@_transparent
public func _assignIfNotEqual<Value: AnyObject>(
    _ value: Value,
    to destination: inout Value?
) {
    if value !== destination {
        destination = value
    }
}

@_spi(Internal)
@_optimize(speed)
@_transparent
public func _assignIfNotEqual<Value: Equatable>(
    _ value: Value,
    to destination: inout Any
) {
    if let _destination = destination as? Value {
        if value != _destination {
            destination = value
        }
    } else {
        destination = value
    }
}

@_spi(Internal)
@_optimize(speed)
@_transparent
public func _assignIfNotEqual<Value: Equatable>(
    _ value: Value,
    to destination: inout Any?
) {
    if let _destination = destination as? Value {
        if value != _destination {
            destination = value
        }
    } else {
        destination = value
    }
}
