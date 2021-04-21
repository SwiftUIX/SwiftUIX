//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A dynamic action.
///
/// Dynamic actions are actions that are reliant on dynamic properties, such as `@Environment`, `@EnvironmentObject` etc. Hence, they conform to `DynamicProperty` themselves, so that the SwiftUI runtime may populate held dynamic properties accordingly.
public protocol DynamicAction: DynamicProperty {
    /// Perform the action represented by this type.
    func perform()
}

// MARK: - API -

extension PerformActionView {
    @inlinable
    public func insertAction<A: DynamicAction>(_ action: A) -> InsertDynamicAction<Self, A> {
        .init(base: self, action: action)
    }
    
    @inlinable
    public func appendAction<A: DynamicAction>(_ action: A) -> AppendDynamicAction<Self, A> {
        .init(base: self, action: action)
    }
    
    @inlinable
    public func addAction<A: DynamicAction>(_ action: A) -> AddDynamicAction<Self, A> {
        .init(base: self, action: action)
    }
}

public struct WithDynamicAction<Action: DynamicAction, Content: View>: View {
    public let action: Action
    public let content: (Action) -> Content
    
    public init(_ action: Action, _ content: @escaping (Action) -> Content) {
        self.action = action
        self.content = content
    }
    
    public var body: some View {
        content(action)
    }
}

public struct DynamicActionButton<Action: DynamicAction, Label: View>: View {
    public let action: Action
    public let label: Label
    
    public init(
        action: Action,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: action.perform) {
            label
        }
    }
}

extension View {
    public func onPress<A: DynamicAction>(perform action: A) -> some View {
        DynamicActionButton(action: action) {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    public func onPress(perform action: @escaping () -> Void) -> some View {
        onPress(perform: Action(action))
    }
}

// MARK: - Auxiliary Implementation -

public struct InsertDynamicAction<Base: PerformActionView, Action: DynamicAction>: View {
    public let base: Base
    public let action: Action
    
    public init(base: Base, action: Action) {
        self.base = base
        self.action = action
    }
    
    @inlinable
    public var body: some View {
        base.transformAction({ $0.insert(action.perform) })
    }
}

public struct AppendDynamicAction<Base: PerformActionView, Action: DynamicAction>: View {
    public let base: Base
    public let action: Action
    
    public init(base: Base, action: Action) {
        self.base = base
        self.action = action
    }
    
    @inlinable
    public var body: some View {
        base.transformAction({ $0.insert(action.perform) })
    }
}

public struct AddDynamicAction<Base: PerformActionView, Action: DynamicAction>: View {
    public let base: Base
    public let action: Action
    
    public init(base: Base, action: Action) {
        self.base = base
        self.action = action
    }
    
    @inlinable
    public var body: some View {
        base.addAction(action)
    }
}
