//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct _WithDynamicPropertyExistential<Property, Content: View>: View {
    private let property: Property
    private let content: (Property) -> Content
    
    public init(
        _ property: Property,
        @ViewBuilder content: @escaping (Property) -> Content
    ) {
        self.property = property
        self.content = content
    }
    
    public init(
        _ property: Property,
        @ViewBuilder content: @escaping (Property) -> any View
    ) where Content == AnyView {
        self.property = property
        self.content = { content($0).eraseToAnyView() }
    }
    
    public var body: some View {
        (property as! DynamicProperty)._opaque_makeWithDynamicPropertyGuts(content: content)
    }
}

// MARK: - Internal

fileprivate struct _WithDynamicPropertyExistentialGuts<Property: DynamicProperty, Content: View>: View {
    let property: Property
    let content: (Property) -> Content
    
    var body: some View {
        content(property)
    }
}

extension DynamicProperty {
    fileprivate func _opaque_makeWithDynamicPropertyGuts<Property, Content: View>(
        content: @escaping (Property) -> Content
    ) -> AnyView {
        _WithDynamicPropertyExistentialGuts(
            property: self,
            content: { content($0 as! Property) }
        )
        .eraseToAnyView()
    }
}
