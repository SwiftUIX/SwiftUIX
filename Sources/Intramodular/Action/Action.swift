//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A convenience around a closure of the type `() -> Void`.
public struct Action: Hashable {
    public static let empty = Action({ })
    
    private var value: @convention(block) () -> Void
    
    public init(_ value: @escaping () -> Void) {
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        unsafeBitCast((value as AnyObject), to: UnsafeRawPointer.self).hash(into: &hasher)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.value as AnyObject) === (rhs.value as AnyObject)
    }
    
    public func perform() {
        value()
    }
    
    public func insert(_ action: Action) -> Action {
        .init {
            action.perform()
            self.perform()
        }
    }
    
    public func insert(_ action: @escaping () -> Void) -> Action {
        .init {
            action()
            self.perform()
        }
    }
    
    public func append(_ action: Action) -> Action {
        .init {
            self.perform()
            action.perform()
        }
    }
    
    public func append(_ action: @escaping () -> Void) -> Action {
        .init {
            self.perform()
            action()
        }
    }
}

// MARK: - API -

public struct PeformAction: ActionInitiable, PerformActionView {
    private let action: Action
    
    public init(action: Action) {
        self.action = action
    }
    
    public var body: some View {
        DispatchQueue.main.async {
            self.action.perform()
        }
        
        return ZeroSizeView()
    }
    
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        .init(action: transform(action))
    }
}

// MARK: - Helpers -

public protocol ActionInitiable {
    init(action: Action)
}

extension ActionInitiable {
    public init(action: @escaping () -> Void) {
        self.init(action: .init(action))
    }
}
