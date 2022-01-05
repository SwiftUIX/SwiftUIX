//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@propertyWrapper
public struct OptionalObservedObject<ObjectType: ObservableObject>: DynamicProperty {
    public typealias Container = _OptionalObservedObjectContainer<ObjectType>
    
    private let base: ObjectType?

    @State fileprivate var container: Container
    @ObservedObject fileprivate var observedContainer: Container

    /// The current state value.
    public var wrappedValue: ObjectType? {
        get {
            container.base
        } nonmutating set {
            container.base = newValue
        }
    }

    /// Initialize with the provided initial value.
    public init(wrappedValue value: ObjectType?) {
        let container = Container(base: value)

        self.base = value
        self.container = container
        self.observedContainer = container
    }

    public init() {
        self.init(wrappedValue: nil)
    }

    public mutating func update() {
        withExtendedLifetime(container) {
            withExtendedLifetime(container.base) {
                if container !== observedContainer {
                    observedContainer = self.container
                }
            }
        }
    }
}

// MARK: - Auxiliary Implementation -

public final class _OptionalObservedObjectContainer<ObjectType: ObservableObject>: ObservableObject {
    private var baseSubscription: AnyCancellable?
    
    fileprivate var base: ObjectType? {
        didSet {
            if let oldValue = oldValue, let base = base {
                if oldValue === base, baseSubscription != nil {
                    return
                }
            }
            
            subscribe()
        }
    }
    
    fileprivate init(base: ObjectType?) {
        self.base = base
        
        withExtendedLifetime(self) {
            withExtendedLifetime(base) {
                subscribe()
            }
        }
    }
    
    private func subscribe() {
        guard let base = base else {
            return
        }
        
        baseSubscription = base
            .objectWillChange
            .sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
    }
}
