//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicAction: DynamicProperty {
    func perform()
}

// MARK: - API -

extension PerformActionView {
    public func insertAction<A: DynamicAction>(_ action: A) -> InsertDynamicAction<Self, A> {
        .init(base: self, action: action)
    }
    
    public func appendAction<A: DynamicAction>(_ action: A) -> AppendDynamicAction<Self, A> {
        .init(base: self, action: action)
    }
    
    public func addAction<A: DynamicAction>(_ action: A) -> AddDynamicAction<Self, A> {
        .init(base: self, action: action)
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
    
    public var body: some View {
        base.addAction(perform: action.perform)
    }
}
