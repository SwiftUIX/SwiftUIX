//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

final class _OptionalObservedObjectContainer<ObjectType: ObservableObject>: ObservableObject {
    private var baseSubscription: AnyCancellable?
    
    var onObjectWillChange: () -> Void = { }
    
    var base: ObjectType? {
        didSet {
            if let oldValue = oldValue, let base = base {
                if oldValue === base, baseSubscription != nil {
                    return
                }
            }
            
            subscribe()
        }
    }
    
    init(base: ObjectType? = nil) {
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
