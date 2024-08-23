//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
public struct _WithDynamicPropertyExistential<Property>: DynamicProperty, View {
    private let property: Property
    private let content: (Property) -> (any View)
    
    public init(
        _ property: Property,
        @ViewBuilder content: @escaping (Property) -> any View
    ) {
        self.property = property
        self.content = content
    }
    
    public init<C: View>(
        _ property: Property,
        @ViewBuilder content: @escaping (Property) -> C
    ) {
        self.property = property
        self.content = { content($0) as (any View) }
    }
    
    public var body: some View {
        (property as! DynamicProperty)._opaque_makeWithDynamicPropertyGuts(content: content)
    }
    
    /// This is needed because in `_WithDynamicPropertyExistential` SwiftUI doesn't update `property`.
    fileprivate struct Guts: DynamicProperty, View {
        let property: Property
        let content: (Property) -> (any View)
        
        var body: some View {
            content(property).eraseToAnyView()
        }
    }
}

// MARK: - Internal

extension DynamicProperty {
    fileprivate func _opaque_makeWithDynamicPropertyGuts<T>(
        content: @escaping (T) -> any View
    ) -> AnyView {
        _WithDynamicPropertyExistential.Guts(
            property: self,
            content: { content($0 as! T) }
        )
        .eraseToAnyView()
    }
}
