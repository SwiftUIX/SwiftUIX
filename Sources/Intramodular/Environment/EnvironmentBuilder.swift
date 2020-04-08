//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// Builds an environment for a given view.
public struct EnvironmentBuilder {
    @usableFromInline
    var descriptionObjects: [Any] = []
    
    @usableFromInline
    var environmentValuesTransforms: [(inout EnvironmentValues) -> Void] = []
    
    @usableFromInline
    var environmentObjectTransforms: [ObjectIdentifier: (AnyView) -> AnyView] = [:]
    
    public var isEmpty: Bool {
        environmentObjectTransforms.isEmpty && environmentValuesTransforms.isEmpty
    }
    
    @inlinable
    public init() {
        
    }
}

extension EnvironmentBuilder {
    @inlinable
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void) {
        environmentValuesTransforms.append(transform)
    }
    
    @inlinable
    public mutating func insert<B: ObservableObject>(_ bindable: B) {
        descriptionObjects.append(bindable)
        
        environmentObjectTransforms[ObjectIdentifier(type(of: bindable))] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    @inlinable
    public mutating func merge(_ builder: EnvironmentBuilder) {
        environmentValuesTransforms.append(contentsOf: builder.environmentValuesTransforms)
        environmentObjectTransforms.merge(builder.environmentObjectTransforms) { x, y in x }
        
        descriptionObjects.append(contentsOf: builder.descriptionObjects)
    }
}

// MARK: - Protocol Implementations -

extension EnvironmentBuilder: CustomStringConvertible {
    public var description: String {
        return descriptionObjects.description
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentBuilder {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue = EnvironmentBuilder()
    }
}

extension EnvironmentValues {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            self[EnvironmentBuilder.EnvironmentKey]
        } set {
            self[EnvironmentBuilder.EnvironmentKey] = newValue
        }
    }
}

// MARK: - API -

extension EnvironmentBuilder {
    public static func object<B: ObservableObject>(_ bindable: B) -> Self {
        var result = Self()
        
        result.insert(bindable)
        
        return result
    }
}

extension View {
    @inlinable
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> some View {
        Group {
            if builder.isEmpty {
                self
            } else {
                _mergeEnvironmentBuilder(builder)
            }
        }
    }
    
    @inlinable
    public func _mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> some View {
        var view = eraseToAnyView()
        
        view = builder.environmentObjectTransforms.values.reduce(view, { view, transform in transform(view) })
        
        return view.transformEnvironment(\.self) { environment in
            builder.environmentValuesTransforms.forEach({ $0(&environment) })
        }
        .transformEnvironment(\.environmentBuilder, transform: { $0.merge(builder) })
    }
}
