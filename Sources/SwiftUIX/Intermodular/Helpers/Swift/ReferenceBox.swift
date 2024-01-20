//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A box for arbitrary values.
public protocol _SwiftUIX_AnyValueBox<Value> {
    associatedtype Value
    
    var wrappedValue: Value { get set }
    
    init(wrappedValue: Value)
}

/// A mutable box for arbitrary values.
public protocol _SwiftUIX_AnyMutableValueBox<Value>: _SwiftUIX_AnyValueBox {
    var wrappedValue: Value { get set }
}

public protocol _SwiftUIX_AnyIndirectValueBox<Value> {
    associatedtype Value
    
    var wrappedValue: Value { get nonmutating set }
}

// MARK: - Implemented Conformances

@propertyWrapper
public struct _SwiftUIX_MutableValueBox<Value>: _SwiftUIX_AnyMutableValueBox {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension _SwiftUIX_MutableValueBox: Equatable where Value: Equatable {
    
}

extension _SwiftUIX_MutableValueBox: Hashable where Value: Hashable {
    
}

extension _SwiftUIX_MutableValueBox: Sendable where Value: Sendable {
    
}

@_spi(Internal)
public struct _UnsafeIndirectConstantValueBox<Value>: _SwiftUIX_AnyIndirectValueBox {
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
final class ReferenceBox<T>: _SwiftUIX_AnyIndirectValueBox {
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
final class LazyReferenceBox<T>: _SwiftUIX_AnyIndirectValueBox {
    public typealias Value = T
    
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

@_spi(Internal)
@propertyWrapper
public struct _SwiftUIX_Weak<Value>: _SwiftUIX_AnyMutableValueBox {
    private weak var _weakWrappedValue: AnyObject?
    private var _strongWrappedValue: Value?
    
    public var wrappedValue: Value? {
        get {
            _weakWrappedValue.map({ $0 as! Value }) ?? _strongWrappedValue
        } set {
            if let newValue {
                if type(of: newValue) is AnyClass {
                    _weakWrappedValue = newValue as AnyObject
                } else {
                    _strongWrappedValue = newValue
                }
            } else {
                _weakWrappedValue = nil
                _strongWrappedValue = nil
            }
        }
    }
    
    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(_ value: Value?) {
        self.wrappedValue = value
    }
    
    public init() {
        self.init(wrappedValue: nil)
    }
}

@propertyWrapper
@usableFromInline
final class WeakReferenceBox<T: AnyObject>: _SwiftUIX_AnyIndirectValueBox {
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

@propertyWrapper
final class UnsafeWeakReferenceBox<T>: _SwiftUIX_AnyIndirectValueBox {
    private weak var value: AnyObject?
    
    var wrappedValue: T? {
        get {
            value.map({ $0 as! T })
        } set {
            value = newValue.map({ $0 as AnyObject })
        }
    }
    
    init(_ value: T?) {
        self.value = value.map({ $0 as AnyObject })
    }
    
    init(wrappedValue value: T?) {
        self.value = value.map({ $0 as AnyObject })
    }
}

@_spi(Internal)
@propertyWrapper
public final class _SwiftUIX_ObservableReferenceBox<Value>: ObservableObject {
    @Published public var value: Value
    
    public var wrappedValue: Value {
        get {
            self.value
        } set {
            self.value = newValue
        }
    }
    
    public var projectedValue: _SwiftUIX_ObservableReferenceBox {
        self
    }
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}

@_spi(Internal)
@propertyWrapper
public final class _SwiftUIX_ObservableWeakReferenceBox<T: AnyObject>: ObservableObject {
    public weak var value: T? {
        willSet {            
            objectWillChange.send()
        }
    }
    
    public var wrappedValue: T? {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    public init(_ value: T?) {
        self.value = value
    }
}

@_spi(Internal)
@propertyWrapper
public final class _SwiftUIX_WeakObservableReferenceBox<Value: AnyObject>: ObservableObject {
    public weak var value: Value? {
        didSet {
            objectWillChange.send()
        }
    }
    
    public var wrappedValue: Value? {
        get {
            self.value
        } set {
            self.value = newValue
        }
    }
    
    public var projectedValue: _SwiftUIX_WeakObservableReferenceBox<Value> {
        self
    }
    
    public init(_ value: Value?) {
        self.value = value
    }
    
    public convenience init(wrappedValue: Value?) {
        self.init(wrappedValue)
    }
}

@_spi(Internal)
@propertyWrapper
public struct _SwiftUIX_ObjectPointer<Value: AnyObject>: Hashable {
    public var pointee: Value
    
    public var wrappedValue: Value {
        get {
            pointee
        } set {
            pointee = newValue
        }
    }
    
    public init(_ pointee: Value) {
        self.pointee = pointee
    }
    
    public init(wrappedValue: Value) {
        self.init(wrappedValue)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.pointee === rhs.pointee
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(pointee))
    }
}

extension _SwiftUIX_ObjectPointer: @unchecked Sendable where Value: Sendable {
    
}

@_spi(Internal)
@propertyWrapper
public struct _SwiftUIX_WeakObjectPointer<Value: AnyObject>: Hashable {
    public weak var pointee: Value?
    
    public var wrappedValue: Value? {
        get {
            pointee
        } set {
            pointee = newValue
        }
    }
    
    public init(_ pointee: Value?) {
        self.pointee = pointee
    }
    
    public init(wrappedValue: Value?) {
        self.init(wrappedValue)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.pointee === rhs.pointee
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pointee.map(ObjectIdentifier.init))
    }
}

extension _SwiftUIX_WeakObjectPointer: @unchecked Sendable where Value: Sendable {
    
}

@frozen
@propertyWrapper
public struct _SwiftUIX_Metatype<T>: CustomStringConvertible, Hashable {
    @usableFromInline
    let _wrappedValue: Any.Type
    
    public let wrappedValue: T
    
    public var description: String {
        String(describing: wrappedValue)
    }
    
    public init(wrappedValue: T) {
        self._wrappedValue = wrappedValue as! Any.Type
        self.wrappedValue = wrappedValue
    }
    
    public init(_ value: T) {
        self.init(wrappedValue: value)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._wrappedValue == rhs._wrappedValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(_wrappedValue))
    }
}
