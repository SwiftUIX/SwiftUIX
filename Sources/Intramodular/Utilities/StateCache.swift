//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol StateCache {
    func cache<T>(_ value: T, forKey key: AnyHashable) throws
    func decache<T>(_ type: T.Type, forKey key: AnyHashable) throws -> T?
    
    func removeCachedValue(forKey key: AnyHashable)
    func removeAllCachedValues()
}

// MARK: - Default Implementation -

@usableFromInline
final class InMemoryStateCache: StateCache {
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
struct StateCacheEnvironmentKey: EnvironmentKey {
    @usableFromInline
    static let defaultValue: StateCache = InMemoryStateCache()
}

extension EnvironmentValues {
    @inlinable
    public var cache: StateCache {
        get {
            self[StateCacheEnvironmentKey.self]
        } set {
            self[StateCacheEnvironmentKey.self] = newValue
        }
    }
}

@propertyWrapper
public struct _UniqueStateCache: DynamicProperty, StateCache {
    private struct CacheKey: Hashable {
        let base: AnyHashable
        let parentID: AnyHashable
    }
    
    @State private var id: AnyHashable
    
    @Environment(\.cache) private var cache: StateCache
    
    public var wrappedValue: StateCache {
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

extension View {
    public typealias UniqueCache = _UniqueStateCache
}
