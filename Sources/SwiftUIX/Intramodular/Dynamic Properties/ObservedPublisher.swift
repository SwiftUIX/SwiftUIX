//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A dynamic view property that subscribes to a `Publisher` automatically invalidating the view when it publishes.
@propertyWrapper
public struct ObservedPublisher<P: Publisher>: DynamicProperty where P.Failure == Never {
    private let publisher: P
    
    @State var subscription: AnyCancellable? = nil
    
    private var updateWrappedValue = ReferenceBox<(P.Output) -> Void>({ _ in })
    
    @State public private(set) var wrappedValue: P.Output
    
    public init(publisher: P, initial: P.Output) {
        self.publisher = publisher
        self._wrappedValue = .init(initialValue: initial)
        
        let updateWrappedValue = self.updateWrappedValue
        
        self._subscription = .init(
            initialValue: Publishers.Concatenate(
                prefix: Just(initial)
                    .delay(for: .nanoseconds(1), scheduler: DispatchQueue.main),
                suffix: publisher
            ).sink(receiveValue: {
                updateWrappedValue.value($0)
            })
        )
    }
    
    public mutating func update() {
        let _wrappedValue = self._wrappedValue
        
        updateWrappedValue.value = { _wrappedValue.wrappedValue = $0 }
    }
}
