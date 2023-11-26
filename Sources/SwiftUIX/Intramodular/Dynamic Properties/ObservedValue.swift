//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@dynamicMemberLookup
@propertyWrapper
public struct ObservedValue<Value>: DynamicProperty {
    @ObservedObject var base: AnyObservableValue<Value>
    
    public var wrappedValue: Value {
        get {
            base.wrappedValue
        } nonmutating set {
            base.wrappedValue = newValue
        }
    }
    
    public var projectedValue: ObservedValue<Value> {
        self
    }
    
    public var binding: Binding<Value> {
        .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> ObservedValue<Subject> {
        .init(base[dynamicMember: keyPath])
    }
}

// MARK: - API

extension ObservedValue {
    public init(_ base: AnyObservableValue<Value>) {
        self.base = base
    }
    
    public init<Root>(
        _ keyPath: WritableKeyPath<Root, Value>,
        on root: ObservedValue<Root>
    ) {
        self = root[dynamicMember: keyPath]
    }
    
    public init<Root: ObservableObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, Value>,
        on root: Root
    ) {
        self.init(ObservableValues.ObjectMember(root: root, keyPath: keyPath))
    }
    
    public static func constant(
        _ value: Value
    ) -> ObservedValue<Value> {
        self.init(ObservableValues.Root(root: value))
    }
}

extension View {
    public func modify<T, TransformedView: View>(
        observing storage: ViewStorage<T>,
        transform: @escaping (AnyView, T) -> TransformedView
    ) -> some View {
        WithObservedValue(value: .init(storage), content: { transform(AnyView(self), $0) })
    }
    
    public func modify<T, TransformedView: View>(
        observing storage: ViewStorage<T>?,
        transform: @escaping (AnyView, T?) -> TransformedView
    ) -> some View {
        WithOptionalObservableValue(value: storage.map(ObservedValue.init)?.base, content: { transform(AnyView(self), $0) })
    }
    
    public func modify<T: Hashable, TransformedView: View>(
        observing storage: ViewStorage<T>,
        transform: @escaping (AnyView) -> TransformedView
    ) -> some View {
        WithObservedValue(value: .init(storage), content: { transform(AnyView(self.background(EmptyView().id($0)))) })
    }
}

// MARK: - Auxiliary

private struct WithObservedValue<T, Content: View>: View {
    @ObservedValue var value: T
    
    let content: (T) -> Content
    
    var body: some View {
        content(value)
    }
}

private struct WithOptionalObservableValue<T, Content: View>: View {
    @ObservedObject.Optional var value: AnyObservableValue<T>?
    
    let content: (T?) -> Content
    
    var body: some View {
        content(value?.wrappedValue)
    }
}
