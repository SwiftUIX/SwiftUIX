//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@MainActor
public func withInlineState<Content: View>(
    _ type: Bool.Type,
    @ViewBuilder content: @escaping (Binding<Bool>) -> Content
) -> some View {
    WithInlineState(initialValue: false, content: content)
}

@MainActor
public func withInlineState<Value, Content: View>(
    initialValue: Value,
    @ViewBuilder content: @escaping (Binding<Value>) -> Content
) -> some View {
    WithInlineState(initialValue: initialValue, content: content)
}

@_disfavoredOverload
@MainActor
public func withInlineObservedObject<Object: ObservableObject, Content: View>(
    _ object: Object,
    @ViewBuilder content: @escaping (Object) -> Content
) -> some View {
    WithInlineObservedObject(object, content: { content($0.wrappedValue) })
}

@MainActor
public func withInlineObservedObject<Object: ObservableObject, Content: View>(
    _ object: Object,
    @ViewBuilder content: @escaping (ObservedObject<Object>.Wrapper) -> Content
) -> some View {
    WithInlineObservedObject(object, content: { content($0.projectedValue) })
}

@MainActor
public func withInlineObservedObject<Object: ObservableObject, Content: View>(
    _ object: Object?,
    @ViewBuilder content: (Object?) -> Content
) -> some View {
    WithOptionalInlineObservedObject(object: object, content: content(object))
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
@_disfavoredOverload
@MainActor
public func withInlineStateObject<Object: ObservableObject, Content: View>(
    _ object: @autoclosure @escaping () -> Object,
    @ViewBuilder content: @escaping (Object) -> Content
) -> some View {
    WithInlineStateObject(object(), content: { content($0.wrappedValue) })
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
@_disfavoredOverload
@MainActor
public func withInlineStateObject<Object: ObservableObject, Content: View>(
    _ object: @autoclosure @escaping () -> Object?,
    @ViewBuilder content: @escaping (Object?) -> Content
) -> some View {
    WithInlineOptionalStateObject(object(), content: { content($0.wrappedValue) })
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
@MainActor
public func withInlineStateObject<Object: ObservableObject, Content: View>(
    _ object: @autoclosure @escaping () -> Object,
    @ViewBuilder content: @escaping (ObservedObject<Object>.Wrapper) -> Content
) -> some View {
    WithInlineStateObject(object(), content: { content($0.projectedValue) })
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@MainActor
public func withInlineTimerState<Content: View>(
    interval: TimeInterval,
    @ViewBuilder content: @escaping (Int) -> Content
) -> some View {
    WithInlineTimerState(interval: interval, content: content)
}

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

private struct WithInlineObservedObject<Object: ObservableObject, Content: View>: View {
    @ObservedObject var object: Object
    
    let content: (ObservedObject<Object>) -> Content
    
    init(
        _ object: Object,
        @ViewBuilder content: @escaping (ObservedObject<Object>) -> Content
    ) {
        self.object = object
        self.content = content
    }
    
    var body: some View {
        content(_object)
    }
}

private struct WithOptionalInlineObservedObject<Object: ObservableObject, Content: View>: View {
    @ObservedObject.Optional var object: Object?
    
    let content: Content
    
    var body: some View {
        content
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
private struct WithInlineStateObject<Object: ObservableObject, Content: View>: View {
    @StateObject var object: Object
    
    let content: (StateObject<Object>) -> Content
    
    init(
        _ object: @autoclosure @escaping () -> Object,
        @ViewBuilder content: @escaping (StateObject<Object>) -> Content
    ) {
        self._object = .init(wrappedValue: object())
        self.content = content
    }
    
    var body: some View {
        content(_object)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
private struct WithInlineOptionalStateObject<Object: ObservableObject, Content: View>: View {
    @StateObject.Optional var object: Object?
    
    let content: (StateObject<Object>.Optional) -> Content
    
    init(
        _ object: @autoclosure @escaping () -> Object?,
        @ViewBuilder content: @escaping (StateObject<Object>.Optional) -> Content
    ) {
        self._object = .init(wrappedValue: object())
        self.content = content
    }
    
    var body: some View {
        content(_object)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct WithInlineTimerState<Content: View>: View {
    @TimerState var value: Int
    
    let content: (Int) -> Content
    
    init(
        interval: TimeInterval,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self._value = TimerState(interval: interval)
        self.content = content
    }
    
    var body: some View {
        content(value)
    }
}
