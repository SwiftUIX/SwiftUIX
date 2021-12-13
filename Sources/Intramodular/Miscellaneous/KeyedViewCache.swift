//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@usableFromInline
protocol KeyedViewCache {
    func cache<T>(_ value: T, forKey key: AnyHashable) throws
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T?
    func removeCachedValue(forKey key: AnyHashable)
    func removeAllCachedValues()
}

// MARK: - Default Implementation -

@usableFromInline
final class InMemoryKeyedViewCache: KeyedViewCache {
    enum Error: Swift.Error {
        case typeMismatch
    }
    
    private var storage: [AnyHashable: Any] = [:]
    
    init() {
        
    }
    
    @usableFromInline
    func cache<T>(_ value: T, forKey key: AnyHashable) throws {
        storage[key] = value
    }
    
    @usableFromInline
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T? {
        guard let value = storage[key] else {
            return nil
        }
        
        guard let castValue = value as? T else {
            throw Error.typeMismatch
        }
        
        return castValue
    }
    
    @usableFromInline
    func removeCachedValue(forKey key: AnyHashable) {
        storage.removeValue(forKey: key)
    }
    
    @usableFromInline
    func removeAllCachedValues() {
        storage.removeAll()
    }
}

// MARK: - Auxiliary Implementation -

@usableFromInline
struct KeyedViewCacheEnvironmentKey: EnvironmentKey {
    @usableFromInline
    static let defaultValue: KeyedViewCache = InMemoryKeyedViewCache()
}

extension EnvironmentValues {
    @usableFromInline
    var cache: KeyedViewCache {
        get {
            self[KeyedViewCacheEnvironmentKey.self]
        } set {
            self[KeyedViewCacheEnvironmentKey.self] = newValue
        }
    }
}

@propertyWrapper
@usableFromInline
struct _UniqueKeyedViewCache: DynamicProperty, KeyedViewCache {
    private struct CacheKey: Hashable {
        let base: AnyHashable
        let parentID: AnyHashable
    }
    
    @State private var id: AnyHashable
    
    @Environment(\.cache) private var cache: KeyedViewCache
    
    @usableFromInline
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
    
    @usableFromInline
    func cache<T>(_ value: T, forKey key: AnyHashable) throws {
        try cache.cache(value, forKey: CacheKey(base: key, parentID: id))
    }
    
    @usableFromInline
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T? {
        try cache.decache(type, forKey: CacheKey(base: key, parentID: id))
    }
    
    @usableFromInline
    func removeCachedValue(forKey key: AnyHashable) {
        cache.removeCachedValue(forKey: key)
    }
    
    @usableFromInline
    func removeAllCachedValues() {
        cache.removeAllCachedValues()
    }
}
