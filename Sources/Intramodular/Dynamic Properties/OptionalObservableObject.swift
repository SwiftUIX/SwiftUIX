//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@propertyWrapper
public struct OptionalObservedObject<ObjectType: ObservableObject>: DynamicProperty {
    @usableFromInline
    @ObservedObject var _wrappedValue: OptionalObservableObject<ObjectType>
    
    /// The current state value.
    @inlinable
    public var wrappedValue: ObjectType? {
        get {
            _wrappedValue.base
        } nonmutating set {
            _wrappedValue.base = newValue
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    @inlinable
    public var projectedValue: Binding<ObjectType?> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    /// Initialize with the provided initial value.
    @inlinable
    public init(wrappedValue value: ObjectType?) {
        self._wrappedValue = .init(base: value)
    }
    
    @inlinable
    public init() {
        self.init(wrappedValue: nil)
    }
}

// MARK: - Auxiliary Implementation -

@usableFromInline
final class OptionalObservableObject<ObjectType: ObservableObject>: ObservableObject {
    @usableFromInline
    var baseSubscription: AnyCancellable?
    
    @usableFromInline
    var base: ObjectType? {
        didSet {
            subscribe()
        }
    }
    
    @usableFromInline
    init(base: ObjectType?) {
        self.base = base
        
        subscribe()
    }
    
    @usableFromInline
    func subscribe() {
        baseSubscription = base?.objectWillChange.sink(receiveValue: { [unowned self] _ in
            self.objectWillChange.send()
        })
    }
}
