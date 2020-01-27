//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct EnvironmentBuilder {
    fileprivate var descriptionObjects: [Any] = []
    
    fileprivate var environmentValuesTransforms: [(inout EnvironmentValues) -> Void] = []
    fileprivate var environmentTransforms: [ObjectIdentifier: (AnyView) -> AnyView] = [:]
    fileprivate var otherTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]
    
    public var isEmpty: Bool {
        environmentTransforms.isEmpty && otherTransforms.isEmpty
    }
    
    public init() {
        
    }
    
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void) {
        environmentValuesTransforms.append(transform)
    }
    
    public mutating func insert<B: ObservableObject>(_ bindable: B) {
        descriptionObjects.append(bindable)
        
        environmentTransforms[ObjectIdentifier(type(of: bindable))] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    public mutating func set<H: Hashable, V: View>(
        _ transform: @escaping (AnyView) -> V,
        forKey key: H
    ) {
        otherTransforms[AnyHashable(key)] = { transform($0).eraseToAnyView() }
    }
    
    public mutating func merge(_ builder: EnvironmentBuilder) {
        environmentValuesTransforms.append(contentsOf: builder.environmentValuesTransforms)
        
        for (key, value) in builder.environmentTransforms {
            environmentTransforms[key] = value
        }
        
        for (key, value) in builder.otherTransforms {
            otherTransforms[key] = value
        }
        
        descriptionObjects.append(contentsOf: builder.descriptionObjects)
    }
    
    public func transform<V: View>(_ view: V) -> AnyView {
        var view = view.eraseToAnyView()
        
        view = environmentTransforms.values.reduce(view, { view, transform in transform(view) })
        view = otherTransforms.values.reduce(view, { view, transform in transform(view) })
        view = view.transformEnvironment(\.self) { (environment: inout EnvironmentValues) in
            self.environmentValuesTransforms.forEach({ $0(&environment) })
        }
        .transformEnvironment(\.environmentBuilder, transform: { $0.merge(self) })
        .eraseToAnyView()
        
        return view
    }
}

extension EnvironmentBuilder {
    public static func object<B: ObservableObject>(_ bindable: B) -> Self {
        var result = Self()
        
        result.insert(bindable)
        
        return result
    }
}

// MARK: - Protocol Implementations -

extension EnvironmentBuilder: CustomStringConvertible {
    public var description: String {
        return descriptionObjects.description
    }
}

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

// MARK: - Helpers -

extension View {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> some View {
        Group {
            if builder.isEmpty {
                self
            } else {
                builder.transform(self)
            }
        }
    }
}
