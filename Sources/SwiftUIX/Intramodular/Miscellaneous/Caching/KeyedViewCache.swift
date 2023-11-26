//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

protocol KeyedViewCache {
    func cache<T>(_ value: T, forKey key: AnyHashable) throws
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T?
    func removeCachedValue(forKey key: AnyHashable)
    func removeAllCachedValues()
}

// MARK: - Default Implementation

final class InMemoryKeyedViewCache: KeyedViewCache {
    enum Error: Swift.Error {
        case typeMismatch
    }
    
    private var storage: [AnyHashable: Any] = [:]
    
    init() {
        
    }
    
    func cache<T>(_ value: T, forKey key: AnyHashable) throws {
        storage[key] = value
    }
    
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T? {
        guard let value = storage[key] else {
            return nil
        }
        
        guard let castValue = value as? T else {
            throw Error.typeMismatch
        }
        
        return castValue
    }
    
    func removeCachedValue(forKey key: AnyHashable) {
        storage.removeValue(forKey: key)
    }
    
    func removeAllCachedValues() {
        storage.removeAll()
    }
}

// MARK: - Auxiliary

struct KeyedViewCacheEnvironmentKey: EnvironmentKey {
    static let defaultValue: KeyedViewCache = InMemoryKeyedViewCache()
}

extension EnvironmentValues {
    var cache: KeyedViewCache {
        get {
            self[KeyedViewCacheEnvironmentKey.self]
        } set {
            self[KeyedViewCacheEnvironmentKey.self] = newValue
        }
    }
}

@propertyWrapper
struct _UniqueKeyedViewCache: DynamicProperty, KeyedViewCache {
    private struct CacheKey: Hashable {
        let base: AnyHashable
        let parentID: AnyHashable
    }
    
    @State private var id: AnyHashable
    
    @Environment(\.cache) private var cache: KeyedViewCache
    
    var wrappedValue: KeyedViewCache {
        self
    }
    
    init(id: AnyHashable) {
        self._id = .init(initialValue: id)
    }
    
    init(for type: Any.Type) {
        self._id = .init(initialValue: AnyHashable(ObjectIdentifier(type)))
    }
    
    init() {
        self._id = .init(initialValue: AnyHashable(UUID()))
    }
    
    func cache<T>(_ value: T, forKey key: AnyHashable) throws {
        try cache.cache(value, forKey: CacheKey(base: key, parentID: id))
    }
    
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T? {
        try cache.decache(type, forKey: CacheKey(base: key, parentID: id))
    }
    
    func removeCachedValue(forKey key: AnyHashable) {
        cache.removeCachedValue(forKey: key)
    }
    
    func removeAllCachedValues() {
        cache.removeAllCachedValues()
    }
}
