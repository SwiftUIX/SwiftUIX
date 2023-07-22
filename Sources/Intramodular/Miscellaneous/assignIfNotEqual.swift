//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_spi(Internal)
@inlinable
public func _assignIfNotEqual<Value: Equatable>(
    _ value: Value,
    to destination: inout Value
) {
    if value != destination {
        destination = value
    }
}

@_spi(Internal)
@_disfavoredOverload
@inlinable
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
@inlinable
public func _assignIfNotEqual<Value: AnyObject>(
    _ value: Value,
    to destination: inout Value?
) {
    if value !== destination {
        destination = value
    }
}

@_spi(Internal)
@inlinable
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
@inlinable
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
