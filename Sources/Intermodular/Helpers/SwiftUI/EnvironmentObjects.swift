//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct EnvironmentObjects {
    fileprivate var injectors: [ObjectIdentifier: (AnyView) -> AnyView] = [:]
    
    public init() {
        
    }
    
    public mutating func append<B: ObservableObject>(_ bindable: B) {
        injectors[ObjectIdentifier(type(of: bindable))] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    public mutating func append(contentsOf bindables: EnvironmentObjects) {
        for (key, value) in bindables.injectors {
            injectors[key] = value
        }
    }
}

// MARK: - Helpers -

extension View {
    public func environmentObjects(_ objects: EnvironmentObjects) -> some View {
        objects.injectors.values.reduce(eraseToAnyView(), { view, injector in injector(view) })
    }
}
