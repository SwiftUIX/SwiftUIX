//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

extension ObservedObject {
    /// A property wrapper type that subscribes to an (optional) observable object and invalidates a view whenever the observable object changes.
    @propertyWrapper
    public struct Optional: DynamicProperty {
        private typealias Container = _ObservableObjectBox<ObjectType>
        
        private let base: ObjectType?
        
        @ObservedObject<Container> private var observedContainer = Container(base: nil)
        
        /// The current state value.
        public var wrappedValue: ObjectType? {
            if observedContainer.base !== base {
                observedContainer.base = base
            }
            
            return base
        }
        
        /// Initialize with the provided initial value.
        public init(wrappedValue value: ObjectType?) {
            self.base = value
        }
        
        public mutating func update() {
            _observedContainer.update()
        }
    }
}

@available(*, deprecated, renamed: "ObservedObject.Optional")
public typealias OptionalObservedObject<ObjectType: ObservableObject> = ObservedObject<ObjectType>.Optional
