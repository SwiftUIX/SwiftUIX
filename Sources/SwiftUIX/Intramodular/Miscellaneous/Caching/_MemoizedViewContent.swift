//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// Caches a view against a given value.
///
/// The cache is invalidated when the value changes.
public struct _CacheViewAgainstValue<Value: Equatable, Content: View>: View {
    private let value: Value
    private let content: () -> Content
    
    @ViewStorage
    private var _cachedContent: Content?
    
    public init(
        _ value: Value,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.value = value
        self.content = content
    }
    
    public var body: some View {
        let content: Content = { () -> Content in
            if let _cachedContent {
                return _cachedContent
            } else {
                let content = self.content()
                
                self._cachedContent = content
                
                return content
            }
        }()
        
        content.onChange(of: value) { _ in
            self._cachedContent = nil
        }
    }
}

public struct _MemoizedViewContent<Key: Hashable, Content: View>: View {
    private let key: Key
    private let capacity: Int?
    private let content: (Key) -> Content
    
    @ViewStorage private var cache: [Key: Content] = [:]
    @ViewStorage private var lastCacheEntry: (key: Key, content: Content)?
    
    public init(
        key: Binding<Key>,
        capacity: Int? = 1,
        @ViewBuilder content: @escaping (Key) -> Content
    ) {
        self.key = key.wrappedValue
        self.capacity = capacity
        self.content = content
    }
    
    public init(
        key: Key,
        capacity: Int? = 1,
        @ViewBuilder content: @escaping (Key) -> Content
    ) {
        self.key = key
        self.capacity = capacity
        self.content = content
    }
    
    public init(
        key: Key,
        capacity: Int? = 1,
        @ViewBuilder content: () -> Content
    ) {
        let content = content()
        
        self.key = key
        self.capacity = capacity
        self.content = { _ in content }
    }
    
    public var body: some View {
        retrieveContent(for: key)
    }
    
    @MainActor
    private func retrieveContent(for key: Key) -> Content {
        if let lastCacheEntry, lastCacheEntry.key == key {
            return lastCacheEntry.content
        } else {
            if let cached = cache[key] {
                stash(cached, forKey: key)
                
                return cached
            } else {
                let content = self.content(key)
                
                stash(content, forKey: key)
                
                return content
            }
        }
    }
    
    private func stash(_ content: Content, forKey key: Key) {
        if cache[key] == nil {
            if let capacity, (cache.count + 1) > capacity {
                for key in cache.keys {
                    guard (cache.count + 1) > capacity else {
                        break
                    }
                    
                    cache.removeValue(forKey: key)
                }
            }
            
            cache[key] = content
            lastCacheEntry = (key, content)
        }
        
        if lastCacheEntry == nil || lastCacheEntry?.key != key {
            lastCacheEntry = (key, content)
        }
    }
}
