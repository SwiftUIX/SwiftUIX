//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct EnvironmentObjects {
    fileprivate var environmentTransforms: [ObjectIdentifier: (AnyView) -> AnyView] = [:]
    fileprivate var otherTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]
    
    public init() {
        
    }
    
    public mutating func append<B: ObservableObject>(_ bindable: B) {
        environmentTransforms[ObjectIdentifier(type(of: bindable))] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    public mutating func append(contentsOf bindables: EnvironmentObjects) {
        for (key, value) in bindables.environmentTransforms {
            environmentTransforms[key] = value
        }
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
        
        return view
    }
}

// MARK: - Helpers -

extension View {
    public func environmentObjects(_ objects: EnvironmentObjects) -> some View {
        objects.transform(eraseToAnyView())
    }
}
