//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public final class OptionalObservableObject<ObjectType: ObservableObject>: ObservableObject {
    private var baseSubscription: AnyCancellable?
    
    public fileprivate(set) var base: ObjectType? {
        didSet {
            baseSubscription = base?.objectWillChange.sink(receiveValue: { [unowned self] _ in
                self.objectWillChange.send()
            })
        }
    }
    
    public init(base: ObjectType?) {
        self.base = base
    }
    
    public convenience init() {
        self.init(base: nil)
    }
}

@propertyWrapper
public struct OptionalObservedObject<ObjectType: ObservableObject>: DynamicProperty {
    @ObservedObject private var _wrappedValue: OptionalObservableObject<ObjectType>
    
    /// The current state value.
    public var wrappedValue: ObjectType? {
        get {
            _wrappedValue.base
        } nonmutating set {
            _wrappedValue.base = newValue
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<ObjectType?> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    /// Initialize with the provided initial value.
    public init(wrappedValue value: ObjectType?) {
        self._wrappedValue = .init(base: value)
    }
    
    public init() {
        self.init(wrappedValue: nil)
    }
    
    public mutating func update() {
        self.__wrappedValue.update()
    }
}
