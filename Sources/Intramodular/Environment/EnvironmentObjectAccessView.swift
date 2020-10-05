//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that allows for inlined access to an environment object.
public struct EnvironmentObjectAccessView<Object: ObservableObject, Content: View>: View {
    @EnvironmentObject var object: Object
    
    private let content: (Object) -> Content
    
    public init(
        _: Object.Type = Object.self,
        @ViewBuilder content: @escaping (Object) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(object)
    }
}
