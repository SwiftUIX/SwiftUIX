//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ViewCache {
    func cache<T>(_ value: T, forKey key: AnyHashable) throws
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T?
    
    func removeCachedValue(forKey key: AnyHashable)
    func removeAllCachedValues()
}

// MARK: - Default Implementation -

@usableFromInline
final class InMemoryCache: ViewCache {
    enum Error: Swift.Error {
        case typeMismatch
    }
    
    private var storage: [AnyHashable: Any] = [:]
    
    init() {
        
    }
    
    public func cache<T>(_ value: T, forKey key: AnyHashable) throws {
        storage[key] = value
    }
    
    public func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T? {
        guard let value = storage[key] else {
            return nil
        }
        
        guard let castValue = value as? T else {
            throw Error.typeMismatch
        }
        
        return castValue
    }
    
    public func removeCachedValue(forKey key: AnyHashable) {
        storage.removeValue(forKey: key)
    }
    
    public func removeAllCachedValues() {
        storage.removeAll()
    }
}

// MARK: - Auxiliary Implementation -

@usableFromInline
struct ViewCacheEnvironmentKey: EnvironmentKey {
    @usableFromInline
    static let defaultValue: ViewCache = InMemoryCache()
}

extension EnvironmentValues {
    @inlinable
    public var cache: ViewCache {
        get {
            self[ViewCacheEnvironmentKey.self]
        } set {
            self[ViewCacheEnvironmentKey.self] = newValue
        }
    }
}

@propertyWrapper
public struct UniqueCache: DynamicProperty, ViewCache {
    private struct CacheKey: Hashable {
        let base: AnyHashable
        let parentID: AnyHashable
    }
    
    @State private var id: AnyHashable
    
    @Environment(\.cache) private var cache: ViewCache
    
    public var wrappedValue: ViewCache {
        self
    }
    
    public init(id: AnyHashable) {
        self._id = .init(initialValue: id)
    }
    
    public init(for type: Any.Type) {
        self._id = .init(initialValue: AnyHashable(ObjectIdentifier(type)))
    }
    
    public init() {
        self._id = .init(initialValue: AnyHashable(UUID()))
    }
    
    public func cache<T>(_ value: T, forKey key: AnyHashable) throws {
        try cache.cache(value, forKey: CacheKey(base: key, parentID: id))
    }
    
    public func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T? {
        try cache.decache(type, forKey: CacheKey(base: key, parentID: id))
    }
    
    public func removeCachedValue(forKey key: AnyHashable) {
        cache.removeCachedValue(forKey: key)
    }
    
    public func removeAllCachedValues() {
        cache.removeAllCachedValues()
    }
}
