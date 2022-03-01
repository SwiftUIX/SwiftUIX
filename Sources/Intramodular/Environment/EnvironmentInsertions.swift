//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// Environment values and objects captured for insertion into view hierarchies.
public struct EnvironmentInsertions {
    lazy var environmentValuesTransforms: [AnyHashable: (inout EnvironmentValues) -> Void] = [:]
    lazy var environmentObjectTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]
    lazy var weakEnvironmentObjectTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]

    public init() {
        
    }
}

extension EnvironmentInsertions {
    /// A Boolean value that indicates whether the builder is empty.
    public var isEmpty: Bool {
        var `self` = self
        
        return self.environmentObjectTransforms.isEmpty && self.environmentValuesTransforms.isEmpty
    }
}

extension EnvironmentInsertions {
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void, withKey key: AnyHashable) {
        guard environmentValuesTransforms.index(forKey: key) == nil else {
            return
        }
        
        environmentValuesTransforms[key] = transform
    }
    
    public mutating func transformEnvironment<Key: Hashable>(_ transform: @escaping (inout EnvironmentValues) -> Void, withKey key: Key) {
        transformEnvironment(transform, withKey: .init(key))
    }
    
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void) {
        transformEnvironment(transform, withKey: UUID())
    }
}

extension EnvironmentInsertions {
    private mutating func insert<B: ObservableObject>(_ bindable: B, withKey key: AnyHashable) {
        guard environmentObjectTransforms.index(forKey: key) == nil else {
            return
        }
        
        environmentObjectTransforms[key] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    public mutating func insert<B: ObservableObject>(_ bindable: B) {
        insert(bindable, withKey: ObjectIdentifier(bindable))
    }

    private mutating func insert<B: ObservableObject>(weak bindable: B, withKey key: AnyHashable) {
        guard weakEnvironmentObjectTransforms.index(forKey: key) == nil else {
            return
        }
        
        weakEnvironmentObjectTransforms[key] = { [weak bindable] in
            if let bindable = bindable {
                return $0.environmentObject(bindable).eraseToAnyView()
            } else {
                return $0.eraseToAnyView()
            }
        }
    }
            
    public mutating func insert<B: ObservableObject>(weak bindable: B) {
        insert(weak: bindable, withKey: ObjectIdentifier(bindable))
    }
}

extension EnvironmentInsertions {
    public mutating func merge(_ builder: EnvironmentInsertions?) {
        guard var builder = builder else {
            return
        }
        
        environmentValuesTransforms.merge(builder.environmentValuesTransforms, uniquingKeysWith: { x, y in x })
        environmentObjectTransforms.merge(builder.environmentObjectTransforms, uniquingKeysWith: { x, y in x })
    }
}

// MARK: - API -

extension EnvironmentInsertions {
    public static func value<T>(
        _ value: T,
        forKey keyPath: WritableKeyPath<EnvironmentValues, T>
    ) -> EnvironmentInsertions {
        var result = Self()
        
        result.transformEnvironment {
            $0[keyPath: keyPath] = value
        }
        
        return result
    }
    
    public static func object<B: ObservableObject>(
        _ bindable: B
    ) -> Self {
        var result = Self()
        
        result.insert(bindable)
        
        return result
    }
    
    public static func weakObject<B: ObservableObject>(
        _ bindable: B
    ) -> Self {
        var result = Self()
        
        result.insert(weak: bindable)
        
        return result
    }
}

extension View {
    @ViewBuilder
    public func environment(_ builder: EnvironmentInsertions) -> some View {
        if builder.isEmpty {
            self
        } else {
            _environment(builder)
        }
    }
    
    private func _environment(_ other: EnvironmentInsertions) -> some View {
        var other = other
        
        return other
            .environmentObjectTransforms
            .values
            .reduce(eraseToAnyView(), { view, transform in transform(view) })
            .transformEnvironment(\.self, transform: { environment in
                other.environmentValuesTransforms.values.forEach({ $0(&environment) })
            })
            .transformEnvironment(\._environmentInsertions, transform: {
                $0.merge(other)
            })
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentInsertions {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue = EnvironmentInsertions()
    }
}

extension EnvironmentValues {
    public var _environmentInsertions: EnvironmentInsertions {
        get {
            self[EnvironmentInsertions.EnvironmentKey.self]
        } set {
            self[EnvironmentInsertions.EnvironmentKey.self] = newValue
        }
    }
}
