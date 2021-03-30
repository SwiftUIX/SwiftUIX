//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct WithInlineState<Value, Content: View>: View {
    @State var value: Value
    
    let content: (Binding<Value>) -> Content
    
    init(
        initialValue: Value,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) {
        self._value = .init(initialValue: initialValue)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
private struct WithInlineStateObject<Object: ObservableObject, Content: View>: View {
    @StateObject var object: Object
    
    let content: (Object) -> Content
    
    init(
        _ object: @autoclosure @escaping () -> Object,
        @ViewBuilder content: @escaping (Object) -> Content
    ) {
        self._object = .init(wrappedValue: object())
        self.content = content
    }
    
    var body: some View {
        content(object)
    }
}

public func withInlineState<Value, Content: View>(
    initialValue: Value,
    @ViewBuilder content: @escaping (Binding<Value>) -> Content
) -> some View {
    WithInlineState(initialValue: initialValue, content: content)
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
public func withInlineStateObject<Object: ObservableObject, Content: View>(
    _ object: @autoclosure @escaping () -> Object,
    @ViewBuilder content: @escaping (Object) -> Content
) -> some View {
    WithInlineStateObject(object(), content: content)
}
