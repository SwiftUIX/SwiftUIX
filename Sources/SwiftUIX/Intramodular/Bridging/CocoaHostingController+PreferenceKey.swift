//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public final class _ObservedPreferenceValues: ObservableObject {
    private var observers: [ObjectIdentifier: [(Any) -> Void]] = [:]
    
    @Published private var storage: [ObjectIdentifier: Any] = [:]
    
    public init() {
        
    }
    
    public subscript<Key: PreferenceKey>(
        _ keyType: Key.Type
    ) -> Key.Value? where Key.Value: Equatable {
        get {
            if let _result = storage[ObjectIdentifier(Key.self)] {
                guard let result = _result as? Key.Value else {
                    assertionFailure()
                    
                    return nil
                }
                
                return result
            } else {
                return nil
            }
        } set {
            let key = ObjectIdentifier(keyType)
            
            let oldValue = storage[key] as? Key.Value
            
            guard newValue != oldValue else {
                return
            }
            
            if let newValue {
                storage[key] = newValue
                
                observers[key, default: []].forEach({ $0(newValue) })
            } else {
                storage[key] = nil
            }
        }
    }
    
    public func observe<Key: PreferenceKey>(
        _ key: Key.Type,
        _ operation: @escaping (Key.Value) -> Void
    ) where Key.Value: Equatable {
        self.observers[ObjectIdentifier(key), default: []].append({ value in
            guard let value = value as? Key.Value else {
                assertionFailure()
                
                return
            }
            
            operation(value)
        })
    }
}

struct PreferenceValueObserver<Key: PreferenceKey>: ViewModifier where Key.Value: Equatable {
    weak var store: _ObservedPreferenceValues?
    
    func body(content: Content) -> some View {
        content.onPreferenceChange(Key.self) { [weak store] value in
            store?[Key.self] = value
        }
    }
}
