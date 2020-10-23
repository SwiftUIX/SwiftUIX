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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
public struct WithInlineStateObject<Object: ObservableObject, Content: View>: View {
    @StateObject private var object: Object
    
    private let content: (Object) -> Content
    
    public init(
        _ object: @autoclosure @escaping () -> Object,
        @ViewBuilder content: @escaping (Object) -> Content
    ) {
        self._object = .init(wrappedValue: object())
        self.content = content
    }
    
    public var body: some View {
        content(object)
    }
}
