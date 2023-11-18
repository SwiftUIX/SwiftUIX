//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// An analogue to `PreferenceKey` but for `SwiftUI._ViewTraitKey`.
public protocol _PreferenceTraitKey {
    associatedtype Value: Equatable
    
    static var defaultValue: Value { get }
    
    static func reduce(value: inout Value, nextValue: () -> Value)
}

open class _ArrayReducePreferenceTraitKey<Element: Equatable>: _PreferenceTraitKey {
    public typealias Value = [Element]
    
    public static var defaultValue: Value {
        return []
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Supplementary

extension _ViewTraitValuesProtocol {
    public subscript<Key: _PreferenceTraitKey>(
        _ key: Key.Type
    ) -> Key.Value {
        get {
            self[trait: \._preferenceTraitsStorage][key]
        }
    }
}

extension View {
    public func _preferenceTrait<Key: _PreferenceTraitKey>(
        key: Key.Type,
        value: Key.Value
    ) -> some View {
        modifier(AddPreferenceTrait<Key>(key: key, value: value))
    }
}

// MARK: - Auxiliary

public struct _PreferenceTraitsStorage: Equatable {
    fileprivate var base: [ObjectIdentifier: AnyEquatable] = [:]
    
    fileprivate init(base: [ObjectIdentifier: AnyEquatable]) {
        self.base = base
    }
    
    init() {
        self.init(base: [:])
    }
    
    public subscript<Key: _PreferenceTraitKey>(
        _ key: Key.Type
    ) -> Key.Value {
        get {
            base[ObjectIdentifier(key)].map({ $0.base as! Key.Value }) ?? Key.defaultValue
        } set {
            base[ObjectIdentifier(key)] = AnyEquatable(erasing: newValue)
        }
    }
    
    func merging(_ other: Self) -> Self {
        Self(base: base.merging(other.base, uniquingKeysWith: { lhs, rhs in lhs }))
    }
}

extension _ViewTraitKeys {
    public struct _PreferenceTraitsStorageKey: _ViewTraitKey {
        public static let defaultValue = _PreferenceTraitsStorage()
    }
    
    public var _preferenceTraitsStorage: _PreferenceTraitsStorageKey.Type {
        _PreferenceTraitsStorageKey.self
    }
}

fileprivate struct AddPreferenceTrait<Trait: _PreferenceTraitKey>: ViewModifier {
    let key: Trait.Type
    let value: Trait.Value
    
    func body(content: Content) -> some View {
        _VariadicViewAdapter(content) { content in
            _ForEachSubview(content) { subview in
                transformSubview(subview)
            }
        }
    }
    
    private func transformSubview(
        _ subview: _VariadicViewChildren.Subview
    ) -> some View {
        var subview = subview
        var traits = subview[trait: \._preferenceTraitsStorage]
        
        key._insert(value, into: &traits)
        
        subview[trait: \._preferenceTraitsStorage] = traits
        
        return subview._trait(\._preferenceTraitsStorage, traits)
    }
}

extension _PreferenceTraitKey {
    static func _insert(
        _ value: Value,
        into storage: inout _PreferenceTraitsStorage
    ) {
        var newValue = value
        
        Self.reduce(
            value: &newValue,
            nextValue: { storage[Self.self] }
        )
        
        storage[Self.self] = newValue
    }
}

fileprivate struct AnyEquatable: Equatable {
    @usableFromInline
    var _isEqualTo: ((any Equatable, any Equatable) -> Bool)
    
    let base: any Equatable
    
    init<T: Equatable>(erasing base: T) {
        if let base = base as? AnyEquatable {
            self = base
        } else {
            func equate(_ x: Any, _ y: Any) -> Bool {
                assert(!(x is AnyEquatable))
                assert(!(y is AnyEquatable))
                
                guard let x = x as? T, let y = y as? T else {
                    return false
                }
                
                return x == y
            }
            
            self._isEqualTo = equate
            self.base = base
        }
    }
    
    @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._isEqualTo(lhs.base, rhs.base)
    }
}
