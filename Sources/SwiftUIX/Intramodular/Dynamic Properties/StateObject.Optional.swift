//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
extension StateObject {
    /// A property wrapper type that subscribes to an (optional) observable object and invalidates a view whenever the observable object changes.
    @propertyWrapper
    public struct Optional: DynamicProperty {
        private typealias Container = _ObservableObjectMutableBox<ObjectType, ObjectType?>
        
        private let base: ObjectType?
        
        @StateObject<Container> private var observedContainer = Container(base: nil)
        
        /// The current state value.
        public var wrappedValue: ObjectType? {
            get {
                if observedContainer.base !== base {
                    observedContainer.base = base
                }
                
                return base
            } nonmutating set {
                observedContainer.base = newValue
            }
        }
        
        /// Initialize with the provided initial value.
        public init(wrappedValue value: ObjectType?) {
            self._observedContainer = .init(wrappedValue: .init(base: value))
            self.base = value
        }
        
        public mutating func update() {
            _observedContainer.update()
        }
    }
}
