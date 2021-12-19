//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@usableFromInline
func assignIfNotEqual<Value: Equatable>(
    _ value: Value,
    to destination: inout Value
) {
    if value != destination {
        destination = value
    }
}

@usableFromInline
func assignIfNotEqual<Value: Equatable>(
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

@usableFromInline
func assignIfNotEqual<Value: Equatable>(
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
