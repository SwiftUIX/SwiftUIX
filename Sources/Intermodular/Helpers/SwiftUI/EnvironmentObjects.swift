//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct EnvironmentObjects {
    fileprivate var injectors: [(AnyView) -> AnyView] = []
    
    public init() {
        
    }
    
    public mutating func append<B: ObservableObject>(_ bindable: B) {
        injectors.append({ $0.environmentObject(bindable).eraseToAnyView() })
    }
    
    public mutating func append(contentsOf bindables: EnvironmentObjects) {
        injectors.append(contentsOf: bindables.injectors)
    }
}

// MARK: - Helpers -

extension View {
    public func environmentObjects(_ objects: EnvironmentObjects) -> some View {
        objects.injectors.reduce(eraseToAnyView(), { view, injector in injector(view) })
    }
}
