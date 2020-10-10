//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct WithInlineState<Value, Content: View>: View {
    @State private var value: Value
    
    private let content: (Binding<Value>) -> Content
    
    public init(
        initialValue: Value,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) {
        self._value = .init(initialValue: initialValue)
        self.content = content
    }
    
    public var body: some View {
        content($value)
    }
}
