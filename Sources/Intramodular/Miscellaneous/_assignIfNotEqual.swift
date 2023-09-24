//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_spi(Internal)
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
    @_transparent
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
        }
    }
    
    @_spi(Internal)
    @_transparent
    public func _assignIfNotEqual<Value: Equatable>(
        _ newValue: Value,
        to keyPath: ReferenceWritableKeyPath<Self, Value?>
    ) {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
        }
    }
}
    
@_spi(Internal)
@_disfavoredOverload
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
