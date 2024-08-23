//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import _SwiftUIX
import Combine
import Foundation
import Swift
import SwiftUI

@propertyWrapper
@_documentation(visibility: internal)
public struct UserStorage<Value: Codable>: DynamicProperty {
    @PersistentObject private var valueBox: ValueBox
    
    public var wrappedValue: Value {
        get {
            let result: Value = valueBox.value
            
            return result
        } nonmutating set {
            valueBox.value = newValue
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<Value> {
        return Binding<Value>(
            get: {
                self.wrappedValue
            },
            set: { (newValue: Value) in
                self.wrappedValue = newValue
            }
        )
    }
    
    public func update() {
        self.valueBox._readInitial()
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
                _areValuesEqual: { _, _ in nil },
                _isStrict: _isStrict
            )
        )
    }
    
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard,
        _isStrict: Bool = false
    ) where Value: Equatable {
        self._valueBox = .init(
            wrappedValue: .init(
                key: key,
                defaultValue: wrappedValue,
                store: store,
                _areValuesEqual: { $0 == $1 },
                _isStrict: _isStrict
            )
        )
    }
    
    public init(
        _ key: String,
        store: UserDefaults = .standard,
        _isStrict: Bool = false
    ) where Value: ExpressibleByNilLiteral {
        self.init(
            wrappedValue: nil,
            key,
            store: store,
            _isStrict: _isStrict
        )
    }
    
    public init(
        _ key: String,
        store: UserDefaults = .standard,
        _isStrict: Bool = false
    ) where Value: Equatable & ExpressibleByNilLiteral {
        self.init(
            wrappedValue: nil,
            key,
            store: store,
            _isStrict: _isStrict
        )
    }
}

// MARK: - Conformances

extension UserStorage: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

// MARK: - Auxiliary

extension UserStorage {
    private class ValueBox: ObservableObject {
        private let key: String
        private let defaultValue: Value
        private let store: UserDefaults
        private let _areValuesEqual: (Value, Value) -> Bool?
        private let _isStrict: Bool
        
        fileprivate var storedValue: Value?
        
        private var storeSubscription: AnyCancellable?
        
        private var _isEncodingValueToStore: Bool = false
        
        var value: Value {
            get {
                storedValue ?? defaultValue
            } set {
                do {
                    objectWillChange.send()
                    
                    storedValue = newValue
                    
                    _isEncodingValueToStore = true
                   
                    try store.encode(newValue, forKey: key)
                                        
                    _isEncodingValueToStore = false
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
            _areValuesEqual: @escaping (Value, Value) -> Bool?,
            _isStrict: Bool
        ) {
            self.key = key
            self.defaultValue = defaultValue
            self.store = store
            self._areValuesEqual = _areValuesEqual
            self._isStrict = _isStrict
        }
        
        fileprivate func _readInitial() {
            guard storeSubscription == nil else {
                return
            }
            
            do {
                storedValue = try store.decode(Value.self, forKey: key) ?? defaultValue
            } catch {
                handleError(error)
            }
            
            storeSubscription = store
                .publisher(for: key, type: Any.self)
                .filter { _ in
                    !self._isEncodingValueToStore
                }
                .map {
                    do {
                        return try self.store.decode(Value.self, from: $0)
                    } catch {
                        self.handleError(error)
                        
                        return nil
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (newValue: Value?) in
                    guard let `self` = self else {
                        return
                    }
                    
                    if let oldValue = self.storedValue, let newValue {
                        guard !(self._areValuesEqual(newValue, oldValue) ?? false) else {
                            return
                        }
                    }
                    
                    self.storedValue = newValue
                }
        }
        
        private func handleError(_ error: Error) {
            if _isStrict {
                assertionFailure(String(describing: error))
            } else {
                print(String(describing: error))
            }
        }
    }
}
