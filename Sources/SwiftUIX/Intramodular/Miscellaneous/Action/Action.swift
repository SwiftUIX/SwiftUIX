//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A convenience around a closure of the type `() -> Void`.
@_documentation(visibility: internal)
public struct Action: DynamicAction, Hashable, Identifiable, @unchecked Sendable {
    public let id: AnyHashable?
    
    private let fakeID: AnyHashable?
    private let value: @convention(block) () -> Void
    private var _body: AnyView?

    public init(id: AnyHashable, _ value: @escaping () -> Void) {
        self.value = value
        self.fakeID = nil
        self.id = id
    }
    
    public init(_ value: @escaping () -> Void) {
        self.value = value
        self.fakeID = AnyHashable(UUID())
        self.id = nil
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        
        unsafeBitCast((value as AnyObject), to: UnsafeRawPointer.self).hash(into: &hasher)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.value as AnyObject) === (rhs.value as AnyObject)
    }
    
    public func perform() {
        value()
    }
    
    public func callAsFunction() {
        perform()
    }
}

extension Action: View {
    public var body: some View {
        _body!
    }
    
    @_spi(Internal)
    public init<V: View>(_body: V, id: AnyHashable? = nil) {
        self.id = id
        self.fakeID = nil
        self.value = { }
        self._body = _body.eraseToAnyView()
    }
}

extension Action {
    public func map(_ transform: (Action) -> Action) -> Action {
        transform(self)
    }
    
    public func insert(_ action: Action) -> Action {
        .init {
            action.perform()
            self.perform()
        }
    }
    
    public func insert(_ action: @escaping () -> Void) -> Action {
        insert(Action(action))
    }
    
    public func append(_ action: Action) -> Action {
        .init {
            self.perform()
            action.perform()
        }
    }
    
    public func append(_ action: @escaping () -> Void) -> Action {
        append(Action(action))
    }
    
    public func add(_ action: Action) -> Action {
        action.append(action)
    }
}

// MARK: - API

extension Action {
    public static let empty = Action {
        // do nothing
    }
}

@_documentation(visibility: internal)
public struct PerformAction: _ActionPerformingView {
    private let action: Action
    private let deferred: Bool
    
    public init(
        action: Action,
        deferred: Bool = true
    ) {
        self.action = action
        self.deferred = deferred
    }
    
    public init(
        deferred: Bool = true,
        action: @escaping () -> Void
    ) {
        self.action = .init(action)
        self.deferred = deferred
    }
    
    public var body: ZeroSizeView {
        if deferred {
            DispatchQueue.main.async {
                self.action.perform()
            }
        } else {
            self.action.perform()
        }
        
        return ZeroSizeView()
    }
    
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        .init(action: transform(action))
    }
}

// MARK: - Auxiliary -

public protocol _ActionInitiableView {
    init(action: Action)
}

extension _ActionInitiableView {
    public init(action: @escaping () -> Void) {
        self.init(action: .init(action))
    }
}

public func withActionTrampoline<Content: View>(
    for action: Action,
    @ViewBuilder content: @escaping (Action) -> Content
) -> some View {
    _CreateActionTrampoline(action: action, content: {
        content($0)
    })
}

struct _CreateActionTrampoline<Content: View>: View {
    private let action: Action
    private let content: (Action) -> Content
    
    @State private var id = UUID()

    public init(action: Action, content: @escaping (Action) -> Content) {
        self.action = action
        self.content = content
    }
        
    var body: some View {
        _CreateActionTrampolines(actions: [id: action]) { actions in
            content(actions[id]!)
        }
    }
}

@_spi(Internal)
@_documentation(visibility: internal)
public struct _CreateActionTrampolines<Key: Hashable, Content: View>: View {
    private class ActionTrampoline {
        var base: Action
        
        init(base: Action) {
            self.base = base
        }
        
        func callAsFunction() {
            base()
        }
    }
    
    private let actions: [Key: Action]
    private let content: ([Key: Action]) -> Content
    
    @ViewStorage private var trampolineIdentifiersByKey: [Key: AnyHashable] = [:]
    @ViewStorage private var trampolines: [AnyHashable: ActionTrampoline] = [:]
    
    @State private var stableActions: [Key: Action] = [:]
    
    public init(
        actions: [Key: Action],
        @ViewBuilder content: @escaping ([Key: Action]) -> Content
    ) {
        self.actions = actions
        self.content = content
    }
    
    public var body: some View {
        content(trampolines(for: actions))
    }
    
    private func trampolines(for actions: [Key: Action]) -> [Key: Action] {
        if Set(trampolineIdentifiersByKey.keys) == Set(actions.keys) {
            for (key, newAction) in actions {
                let trampolineID: AnyHashable = trampolineIdentifiersByKey[key]!
                
                trampolines[trampolineID]!.base = newAction
            }
            
            guard Set(stableActions.keys) == Set(actions.keys) else {
                return self._makeStableActions(
                    trampolineIdentifiersByKey: trampolineIdentifiersByKey,
                    trampolines: trampolines
                )
            }
            
            return stableActions
        } else {
            self.trampolineIdentifiersByKey = actions.mapValues({ _ in AnyHashable(UUID()) })
            self.trampolines = Dictionary(uniqueKeysWithValues: trampolineIdentifiersByKey.map({ (key, id) in
                let action = actions[key]!
                
                return (id, ActionTrampoline(base: action))
            }))
            
            let stableActions = self._makeStableActions(
                trampolineIdentifiersByKey: self.trampolineIdentifiersByKey,
                trampolines: self.trampolines
            )
            
            DispatchQueue.main.async {
                self.stableActions = stableActions
            }
            
            return stableActions
        }
    }
    
    private func _makeStableActions(
        trampolineIdentifiersByKey: [Key: AnyHashable],
        trampolines: [AnyHashable: ActionTrampoline]
    ) -> [Key: Action] {
        Dictionary(
            uniqueKeysWithValues: actions.keys.map({ key in
                let trampolineID = trampolineIdentifiersByKey[key]!
                let trampoline = trampolines[trampolineID]!
                
                let action = Action(id: trampolineID) {
                    trampoline()
                }
                
                return (key, action)
            })
        )
    }
}
