//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct EnvironmentObjects {
    fileprivate var environmentValuesTransforms: [(inout EnvironmentValues) -> Void] = []
    fileprivate var descriptionObjects: [Any] = []
    fileprivate var environmentTransforms: [ObjectIdentifier: (AnyView) -> AnyView] = [:]
    fileprivate var otherTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]
    
    public var isEmpty: Bool {
        environmentTransforms.isEmpty && otherTransforms.isEmpty
    }
    
    public init() {
        
    }
    
    public init<B: ObservableObject>(_ bindable: B) {
        self.init()
        
        append(bindable)
    }
    
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void) {
        environmentValuesTransforms.append(transform)
    }
    
    public mutating func append<B: ObservableObject>(_ bindable: B) {
        descriptionObjects.append(bindable)
        
        environmentTransforms[ObjectIdentifier(type(of: bindable))] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    public mutating func append(contentsOf bindables: EnvironmentObjects) {
        for (key, value) in bindables.environmentTransforms {
            environmentTransforms[key] = value
        }
        
        descriptionObjects.append(contentsOf: bindables.descriptionObjects)
    }
    
    public mutating func set<H: Hashable, V: View>(
        _ transform: @escaping (AnyView) -> V,
        forKey key: H
    ) {
        otherTransforms[AnyHashable(key)] = { transform($0).eraseToAnyView() }
    }
    
    public func transform(_ view: AnyView) -> AnyView {
        var view = view
        
        view = environmentTransforms.values.reduce(view, { view, transform in transform(view) })
        view = otherTransforms.values.reduce(view, { view, transform in transform(view) })
        view = view.transformEnvironment(\.self) { (environment: inout EnvironmentValues) in
            self.environmentValuesTransforms.forEach({ $0(&environment) })
        }
        .eraseToAnyView()
        
        return view
    }
}

// MARK: - Protocol Implementations -

extension EnvironmentObjects: CustomStringConvertible {
    public var description: String {
        return descriptionObjects.description
    }
}

extension EnvironmentObjects {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue = EnvironmentObjects()
    }
}

extension EnvironmentValues {
    public var environmentObjects: EnvironmentObjects {
        get {
            self[EnvironmentObjects.EnvironmentKey]
        } set {
            self[EnvironmentObjects.EnvironmentKey] = newValue
        }
    }
}

// MARK: - Helpers -

extension View {
    public func insertEnvironmentObjects(_ objects: EnvironmentObjects) -> some View {
        Group {
            if objects.isEmpty {
                self
            } else {
                objects
                    .transform(eraseToAnyView())
                    .transformEnvironment(\.environmentObjects, transform: {
                        $0.append(contentsOf: objects)
                    })
            }
        }
    }
    
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) -> some View {
        insertEnvironmentObjects(.init(bindable))
    }
}
