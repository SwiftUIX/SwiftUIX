//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift
import SwiftUI

@propertyWrapper
public struct UserStorage<Value: Codable>: DynamicProperty {
    private class ValueBox: ObservableObject {
        let key: String
        let defaultValue: Value
        let store: UserDefaults
        let _isStrict: Bool
        
        var storedValue: Value?
        var storeSubscription: AnyCancellable?
        
        var value: Value {
            get {
                storedValue ?? defaultValue
            } set {
                objectWillChange.send()
                
                do {
                    try store.encode(newValue, forKey: key)
                    
                    storedValue = defaultValue
                } catch {
                    if _isStrict {
                        assertionFailure(String(describing: error))
                    } else {
                        print(String(describing: error))
                    }
                }
            }
        }
        
        init(
            key: String,
            defaultValue: Value,
            store: UserDefaults,
            _isStrict: Bool
        ) {
            self.key = key
            self.defaultValue = defaultValue
            self.store = store
            self._isStrict = _isStrict
            
            do {
                storedValue = try store.decode(Value.self, forKey: key) ?? defaultValue
            } catch {
                if _isStrict {
                    assertionFailure(error.localizedDescription)
                }
            }
            
            storeSubscription = store
                .publisher(for: key, type: Any.self)
                .map {
                    do {
                        return try store.decode(Value.self, from: $0)
                    } catch {
                        if _isStrict {
                            assertionFailure(error.localizedDescription)
                        }
                        
                        return nil
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.storedValue = $0
                }
        }
    }
    
    @State private var dummy: Bool = false
    
    @PersistentObject private var valueBox: ValueBox
    
    public var wrappedValue: Value {
        get {
            valueBox.value
        } nonmutating set {
            valueBox.value = newValue
            
            dummy.toggle()
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard,
        _isStrict: Bool = false
    ) {
        self._valueBox = .init(
            wrappedValue: .init(
                key: key,
                defaultValue: wrappedValue,
                store: store,
                _isStrict: _isStrict
            )
        )
    }
    
    public mutating func update() {
        
    }
}

extension UserStorage where Value: ExpressibleByNilLiteral {
    public init(
        _ key: String,
        store: UserDefaults = .standard,
        _isStrict: Bool = false
    ) {
        self.init(
            wrappedValue: nil,
            key,
            store: store,
            _isStrict: _isStrict
        )
    }
}
