//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A convenience around a closure of the type `() -> Void`.
public struct Action: DynamicAction, Hashable, Identifiable {
    private let value: @convention(block) () -> Void
    
    public let id: AnyHashable
    
    public init(_ value: @escaping () -> Void) {
        self.value = value
        self.id = UUID()
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

// MARK: - API -

extension Action {
    public static let empty = Action {
        // do nothing
    }
}

public struct PerformAction: ActionInitiable, PerformActionView {
    private let action: Action
    
    public init(action: Action) {
        self.action = action
    }
    
    public init(action: @escaping () -> Void) {
        self.action = .init(action)
    }
    
    public var body: some View {
        DispatchQueue.main.async {
            self.action.perform()
        }
        
        return ZeroSizeView()
            .frameZeroClipped()
            .allowsHitTesting(false)
            .accessibility(hidden: true)
    }
    
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        .init(action: transform(action))
    }
}

// MARK: - Auxiliary Implementaton -

public protocol ActionInitiable {
    init(action: Action)
}

extension ActionInitiable {
    public init(action: @escaping () -> Void) {
        self.init(action: .init(action))
    }
}
