//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct WeakBox<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T?) {
        self.value = value
    }
}

@propertyWrapper
@usableFromInline
final class ReferenceBox<T> {
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

@propertyWrapper
@usableFromInline
final class WeakReferenceBox<T: AnyObject> {
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

@usableFromInline
final class ObservableReferenceBox<T>: ObservableObject {
    @usableFromInline
    @Published var value: T
    
    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
}

@usableFromInline
final class ObservableWeakReferenceBox<T: AnyObject>: ObservableObject {
    @usableFromInline
    weak var value: T? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @usableFromInline
    init(_ value: T?) {
        self.value = value
    }
}
