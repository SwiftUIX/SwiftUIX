//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

@_spi(Private)
public final class _ObservableObjectBox<Value>: ObservableObject {
    private var baseSubscription: AnyCancellable?
    
    private var _isNotNil: (Value) -> Bool
    private var _equate: (Value?, Value?) -> Bool
    private var _getObjectWillChange: (Value) -> AnyPublisher<Void, Never>?

    private var onObjectWillChange: () -> Void = { }
    
    @_spi(Private)
    public var base: Value? {
        didSet {
            if _equate(oldValue, base), baseSubscription != nil {
                return
            }

            subscribe()
        }
    }
    
    @_spi(Private)
    public init<T: ObservableObject>(base: T? = nil) where Value == Optional<T> {
        _isNotNil = { $0 != nil }
        _equate = { lhs, rhs in
            if let lhs, let rhs {
                return lhs === rhs
            } else {
                return lhs == nil && rhs == nil
            }
        }
        _getObjectWillChange = { $0?.objectWillChange.map({ _ in () }).eraseToAnyPublisher() }
        
        self.base = base
        
        subscribe()
    }
    
    @_spi(Private)
    public init(base: Value? = nil) where Value: ObservableObject {
        _isNotNil = { _ in true }
        _equate = { $0 === $1 }
        _getObjectWillChange = { $0.objectWillChange.map({ _ in () }).eraseToAnyPublisher() }
        
        self.base = base
        
        subscribe()
    }
    
    private func subscribe() {
        guard let base = base, _isNotNil(base) else {
            baseSubscription?.cancel()
            baseSubscription = nil
            
            return
        }
        
        guard let objectWillChangePublisher = _getObjectWillChange(base) else {
            assertionFailure()
            
            return
        }
        
        baseSubscription = objectWillChangePublisher
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

