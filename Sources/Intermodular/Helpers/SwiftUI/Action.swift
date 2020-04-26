//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct Action: Hashable {
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
}

public struct Actions: Hashable {
    private var value: [Action]
    
    public init(_ value: [Action]) {
        self.value = value
    }
    
    public init(initial action: (Action)) {
        self.init([action])
    }
    
    public init(initial action: @escaping () -> Void) {
        self.init(initial: .init(action))
    }
    
    public init() {
        self.init([])
    }
    
    public mutating func insert(_ action: Action) {
        value.append(action)
    }
    
    public mutating func insert(_ action: @escaping () -> Void) {
        insert(.init(action))
    }
    
    public func perform() {
        value.forEach({ $0.perform() })
    }
}

// MARK: - Usage -

public struct PerformActionView: View {
    private let action: Action
    
    public init(perform action: Action) {
        self.action = action
    }
    
    public init(perform action: @escaping () -> Void) {
        self.action = .init(action)
    }
    
    public var body: some View {
        DispatchQueue.main.async {
            self.action.perform()
        }
        
        return AnyView(EmptyView())
    }
}
