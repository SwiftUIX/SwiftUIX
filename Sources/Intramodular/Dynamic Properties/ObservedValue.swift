//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@dynamicMemberLookup
@propertyWrapper
public struct ObservedValue<Value>: DynamicProperty {
    @ObservedObject var base: ObservableValue<Value>
    
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
    
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> ObservedValue<Subject> {
        .init(base[dynamicMember: keyPath])
    }
}

// MARK: - API -

extension ObservedValue {
    public init(_ base: ObservableValue<Value>) {
        self.base = base
    }
    
    public init<Root>(_ keyPath: WritableKeyPath<Root, Value>, on root: ObservedValue<Root>) {
        self = root[dynamicMember: keyPath]
    }
    
    public init<Root: ObservableObject>(_ keyPath: ReferenceWritableKeyPath<Root, Value>, on root: Root) {
        self.init(ObservableObjectMember(root: root, keyPath: keyPath))
    }
    
    public static func constant(_ value: Value) -> ObservedValue<Value> {
        self.init(ObservableValueRoot(root: value))
    }
}
