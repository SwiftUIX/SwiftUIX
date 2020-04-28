//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@propertyWrapper
public struct ObservedPublisher<P: Publisher>: DynamicProperty where P.Failure == Never {
    private let publisher: P
    
    @State var subscription: AnyCancellable? = nil
    
    private var updateWrappedValue = MutableHeapWrapper<(P.Output) -> Void>({ _ in })
    
    @State public private(set) var wrappedValue: P.Output
    
    public init(publisher: P, initial: P.Output) {
        self.publisher = publisher
        self._wrappedValue = .init(initialValue: initial)
        
        let updateWrappedValue = self.updateWrappedValue
        
        self._subscription = .init(initialValue: publisher.sink(receiveValue: {
            updateWrappedValue.value($0)
        }))
    }
    
    public mutating func update() {
        let _wrappedValue = self._wrappedValue
        
        updateWrappedValue.value = { _wrappedValue.wrappedValue = $0 }
    }
}
