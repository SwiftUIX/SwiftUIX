//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct UnwrapOptionalView<Value, Content: View>: View {
    private let content: Content?
    
    public init(_ value: Optional<Value>, @ViewBuilder content: (Value) -> Content) {
        self.content = value.map(content)
    }
    
    public var body: some View {
        content ?? EmptyView()
    }
}

// MARK: - Helpers -

extension Optional {
    public func ifSome<Content: View>(@ViewBuilder content: (Wrapped) -> Content) -> some View {
        UnwrapOptionalView(self, content: content)
    }
}
