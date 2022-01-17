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
    public func insertAction<A: DynamicAction>(_ action: A) -> _InsertDynamicAction<Self, A> {
        .init(base: self, action: action)
    }

    public func appendAction<A: DynamicAction>(_ action: A) -> _AppendDynamicAction<Self, A> {
        .init(base: self, action: action)
    }

    public func addAction<A: DynamicAction>(_ action: A) -> _AddDynamicAction<Self, A> {
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
    /// Adds an action to perform when this view recognizes a tap gesture.
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    @available(tvOS, unavailable)
    public func onTapGesture<A: DynamicAction>(perform action: A) -> some View {
        modifier(_AddDynamicActionOnTapGesture(action: action))
    }
}

extension View {
    /// Adds an action to perform when this view is pressed.
    ///
    /// - Parameters:
    ///    - action: The action to perform.
    public func onPress<A: DynamicAction>(perform action: A) -> some View {
        DynamicActionButton(action: action) {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Adds an action to perform when this view is pressed.
    ///
    /// - Parameters:
    ///    - action: The action to perform.
    public func onPress(perform action: @escaping () -> Void) -> some View {
        onPress(perform: Action(action))
    }
}

// MARK: - Auxiliary Implementation -

@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
@available(tvOS, unavailable)
struct _AddDynamicActionOnTapGesture<Action: DynamicAction>: ViewModifier {
    let action: Action

    func body(content: Content) -> some View {
        content.onTapGesture {
            action.perform()
        }
    }
}

public struct _InsertDynamicAction<Base: PerformActionView, Action: DynamicAction>: View {
    let base: Base
    let action: Action

    public var body: some View {
        base.transformAction({ $0.insert(action.perform) })
    }
}

public struct _AppendDynamicAction<Base: PerformActionView, Action: DynamicAction>: View {
    let base: Base
    let action: Action

    public var body: some View {
        base.transformAction({ $0.insert(action.perform) })
    }
}

public struct _AddDynamicAction<Base: PerformActionView, Action: DynamicAction>: View {
    let base: Base
    let action: Action

    public var body: some View {
        base.addAction(action)
    }
}
