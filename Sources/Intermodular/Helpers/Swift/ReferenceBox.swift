//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _AnyIndirectValueBox<Value> {
    associatedtype Value
    
    var wrappedValue: Value { get nonmutating set }
}

@_spi(Internal)
public struct _UnsafeIndirectConstantValueBox<Value>: _AnyIndirectValueBox {
    public let _wrappedValue: Value
    
    public var wrappedValue: Value {
        get {
            _wrappedValue
        } nonmutating set {
            assertionFailure()
        }
    }
    
    public init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
}

struct WeakBox<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T?) {
        self.value = value
    }
}

@propertyWrapper
@usableFromInline
final class ReferenceBox<T>: _AnyIndirectValueBox {
    @usableFromInline
    var value: T
    
    @usableFromInline
    var wrappedValue: T {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
    
    @usableFromInline
    init(wrappedValue value: T) {
        self.value = value
    }
}

extension ReferenceBox: @unchecked Sendable where T: Sendable {
    
}

@propertyWrapper
final class LazyReferenceBox<T>: _AnyIndirectValueBox {
    private var initializeValue: (() -> T)?
    private var value: T?
    
    var wrappedValue: T {
        get {
            if let value {
                return value
            } else {
                self.value = initializeValue!()
                self.initializeValue = nil
                
                return self.value!
            }
        } set {
            self.value = newValue
            self.initializeValue = nil
        }
    }
    
    var projectedValue: T? {
        value
    }
    
    init(wrappedValue value: @autoclosure @escaping () -> T) {
        self.initializeValue = value
    }
}

@propertyWrapper
@usableFromInline
final class WeakReferenceBox<T: AnyObject>: _AnyIndirectValueBox {
    @usableFromInline
    weak var value: T?
    
    @usableFromInline
    var wrappedValue: T? {
        get {
            value
        } set {
            value = newValue
        }
    }

    @usableFromInline
    init(_ value: T?) {
        self.value = value
    }
    
    @usableFromInline
    init(wrappedValue value: T?) {
        self.value = value
    }
}

#if canImport(Combine)
import Combine

@usableFromInline
final class ObservableReferenceBox<T>: ObservableObject {
    @usableFromInline
    @Published var value: T
    
    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
}

@propertyWrapper
@usableFromInline
final class ObservableWeakReferenceBox<T: AnyObject>: ObservableObject {
    @usableFromInline
    weak var value: T? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @usableFromInline
    var wrappedValue: T? {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    @usableFromInline
    init(_ value: T?) {
        self.value = value
    }
}
#endif
