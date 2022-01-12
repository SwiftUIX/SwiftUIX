//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A property wrapper type that subscribes to an (optional) observable object and invalidates a view whenever the observable object changes.
@propertyWrapper
public struct OptionalObservedObject<ObjectType: ObservableObject>: DynamicProperty {
    private typealias Container = _OptionalObservedObjectContainer<ObjectType>
    
    @State
    private var dummyStateVariable: Bool = false
    @ObservedObject
    private var dummyObservedObject = _DummyObservableObject()
    @State
    private var base: ObjectType?
    @State
    private var container: Container
    @ObservedObject
    private var observedContainer: Container
    @ObservedObject
    private var observedObject: _AnyObservableObject
    
    /// The current state value.
    public var wrappedValue: ObjectType? {
        get {
            container.base
        } nonmutating set {
            base = newValue
            container.base = newValue
            observedContainer.base = newValue
            
            container.onObjectWillChange = {
                dummyObservedObject.objectWillChange.send()
            }
            
            dummyStateVariable.toggle()
        }
    }
    
    /// Initialize with the provided initial value.
    public init(wrappedValue value: ObjectType?) {
        let container = Container(base: value)
        
        self.container = container
        self.observedContainer = container
        self.observedObject = value.map(_AnyObservableObject.init) ?? .empty
    }
    
    public init() {
        self.init(wrappedValue: nil)
    }
    
    public mutating func update() {
        let container = self.container
        
        if self.observedContainer !== container {
            self.observedContainer = container
        }
        
        if let base = container.base, container.isDirty {
            self.observedContainer = container
            self.observedObject = _AnyObservableObject(base)
            
            container.isDirty = false
        }
    }
}

// MARK: - Auxiliary Implementation -

private class _DummyObservableObject: ObservableObject {
    init() {
        
    }
}

private final class _OptionalObservedObjectContainer<ObjectType: ObservableObject>: ObservableObject {
    private var baseSubscription: AnyCancellable?
    
    var onObjectWillChange: () -> Void = { }
    var isDirty: Bool = false
    
    var base: ObjectType? {
        didSet {
            if let oldValue = oldValue, let base = base {
                if oldValue === base, baseSubscription != nil {
                    return
                }
            }
            
            subscribe()
            
            isDirty = true
        }
    }
    
    init(base: ObjectType?) {
        self.base = base
        
        subscribe()
    }
    
    private func subscribe() {
        guard let base = base else {
            return
        }
        
        baseSubscription = base
            .objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                DispatchQueue.asyncOnMainIfNecessary {
                    `self`.objectWillChange.send()
                    `self`.onObjectWillChange()
                }
            })
    }
}

private final class _AnyObservableObject: ObservableObject {
    private class _EmptyObservableObject: ObservableObject {
        init() {
            
        }
    }
    
    static let empty = _AnyObservableObject(_EmptyObservableObject())
    
    let base: AnyObject
    
    private let objectWillChangeImpl: () -> AnyPublisher<Void, Never>
    
    var objectWillChange: AnyPublisher<Void, Never> {
        objectWillChangeImpl()
    }
    
    init<T: ObservableObject>(_ base: T) {
        self.base = base
        self.objectWillChangeImpl = { base.objectWillChange.map({ _ in () }).eraseToAnyPublisher() }
    }
}
