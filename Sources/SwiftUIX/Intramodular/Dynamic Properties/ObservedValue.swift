//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct ObservedValueConfiguration<Value> {
    public var deferUpdates: Bool = false
    
    public init() {
        
    }
}

@dynamicMemberLookup
@propertyWrapper
@_documentation(visibility: internal)
public struct ObservedValue<Value>: DynamicProperty {
    public var configuration = ObservedValueConfiguration<Value>()
    
    @PersistentObject var base: AnyObservableValue<Value>
    
    public var wrappedValue: Value {
        get {
            base.wrappedValue
        } nonmutating set {
            base.wrappedValue = newValue
        }
    }
    
    public var projectedValue: ObservedValue<Value> {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public var binding: Binding<Value> {
        Binding<Value>(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> ObservedValue<Subject> {
        ObservedValue<Subject>(base[dynamicMember: keyPath])
    }
}

// MARK: - API

extension ObservedValue {
    public init(
        _ base: @autoclosure @escaping () -> AnyObservableValue<Value>
    ) {
        self._base = .init(wrappedValue: base())
    }
    
    public init<Root>(
        _ keyPath: WritableKeyPath<Root, Value>,
        on root: ObservedValue<Root>
    ) {
        self = root[dynamicMember: keyPath]
    }
    
    public init<Root: ObservableObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, Value>,
        on root: Root,
        deferUpdates: Bool? = nil
    ) {
        self.init(
            ObservableValues.ObjectMember(
                root: root,
                keyPath: keyPath,
                configuration: .init(
                    deferUpdates: deferUpdates
                )
            )
        )
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
