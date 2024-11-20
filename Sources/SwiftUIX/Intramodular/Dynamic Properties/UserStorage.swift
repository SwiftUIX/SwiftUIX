//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import _SwiftUIX
import Combine
import Foundation
import Swift
import SwiftUI

public struct UserStorageConfiguration<Value> {
    let key: String
    let defaultValue: Value
    let store: UserDefaults
    var _areValuesEqual: (Value, Value) -> Bool?
    var _isStrict: Bool = false
    var deferUpdates: Bool = false
}

extension UserStorageConfiguration: @unchecked Sendable where Value: Sendable {
    
}

@propertyWrapper
@_documentation(visibility: internal)
public struct UserStorage<Value: Codable>: DynamicProperty {
    public typealias Configuration = UserStorageConfiguration
    
    let configuration: UserStorageConfiguration<Value>
    
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
    
    public mutating func update() {
        self.valueBox._SwiftUI_DynamicProperty_update_called = true
        self.valueBox.configuration = configuration
        self.valueBox._readInitial()
    }
    
    init(configuration: UserStorageConfiguration<Value>) {
        self.configuration = configuration
        self._valueBox = .init(wrappedValue: .init(configuration: configuration))
    }
    
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard,
        _isStrict: Bool = false
    ) {
        self.init(
            configuration: .init(
                key: key,
                defaultValue: wrappedValue,
                store: store,
                _areValuesEqual: { _, _ in nil }
            )
        )
    }
    
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard,
        _isStrict: Bool = false
    ) where Value: Equatable {
        self.init(
            configuration: .init(
                key: key,
                defaultValue: wrappedValue,
                store: store,
                _areValuesEqual: { $0 == $1 }
            )
        )
    }
}

// MARK: - Initializers

extension UserStorage {
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard,
        deferUpdates: Bool
    ) {
        self.init(
            configuration: .init(
                key: key,
                defaultValue: wrappedValue,
                store: store,
                _areValuesEqual: { _, _ in nil },
                deferUpdates: deferUpdates
            )
        )
    }

    public init(
        _ key: String,
        store: UserDefaults = .standard,
        deferUpdates: Bool
    ) where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: nil, key, store: store, deferUpdates: deferUpdates)
    }
    
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard,
        deferUpdates: Bool
    ) where Value: Equatable & ExpressibleByNilLiteral {
        self.init(
            configuration: .init(
                key: key,
                defaultValue: wrappedValue,
                store: store,
                _areValuesEqual: { $0 == $1 },
                deferUpdates: deferUpdates
            )
        )
    }

    public init(
        _ key: String,
        store: UserDefaults = .standard,
        deferUpdates: Bool
    ) where Value: Equatable & ExpressibleByNilLiteral {
        self.init(wrappedValue: nil, key, store: store, deferUpdates: deferUpdates)
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
        fileprivate var _SwiftUI_DynamicProperty_update_called: Bool = false
        
        var configuration: UserStorageConfiguration<Value>
        
        fileprivate var storedValue: Value?
        
        private var storeSubscription: AnyCancellable?
        
        private var _isEncodingValueToStore: Bool = false
        
        var value: Value {
            get {
                _readLatest()
            } set {
                do {
                    if configuration.deferUpdates {
                        Task(priority: .userInitiated) { @MainActor in
                            _objectWillChange_send()
                        }
                    } else {
                        _objectWillChange_send()
                    }
                    
                    storedValue = newValue
                    
                    _isEncodingValueToStore = true
                    
                    try configuration.store.encode(newValue, forKey: configuration.key)
                    
                    _isEncodingValueToStore = false
                } catch {
                    if configuration._isStrict {
                        assertionFailure(String(describing: error))
                    } else {
                        print(String(describing: error))
                    }
                }
            }
        }
        
        init(
            configuration: UserStorageConfiguration<Value>
        ) {
            self.configuration = configuration
        }
        
        fileprivate func _readLatest() -> Value {
            if !_SwiftUI_DynamicProperty_update_called {
                if storedValue == nil && storeSubscription == nil {
                    _readInitial()
                }
            }
            
            let result: Value?
            
            if _SwiftUI_DynamicProperty_update_called {
                result = storedValue ?? configuration.defaultValue
            } else {
                do {
                    result = try configuration.store.decode(Value.self, forKey: configuration.key)
                } catch {
                    debugPrint(error)
                    
                    result = nil
                }
            }
            
            return result ?? configuration.defaultValue
        }
        
        fileprivate func _readInitial() {
            guard storeSubscription == nil else {
                return
            }
            
            do {
                storedValue = try configuration.store.decode(Value.self, forKey: configuration.key) ?? configuration.defaultValue
            } catch {
                handleError(error)
            }
            
            storeSubscription = configuration.store
                .publisher(for: configuration.key, type: Any.self)
                .filter { _ in
                    !self._isEncodingValueToStore
                }
                .map { (value: Any) -> Value? in
                    do {
                        return try self.configuration.store.decode(Value.self, from: value)
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
                        guard !(configuration._areValuesEqual(newValue, oldValue) ?? false) else {
                            return
                        }
                    }
                    
                    self.storedValue = newValue
                }
        }
        
        private func handleError(_ error: Error) {
            if configuration._isStrict {
                assertionFailure(String(describing: error))
            } else {
                print(String(describing: error))
            }
        }
    }
}
