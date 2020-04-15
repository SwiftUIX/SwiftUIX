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

public struct Actions {
    public typealias Action = () -> Void
    
    private var value: [Action]
    
    public init(_ value: [Action]) {
        self.value = value
    }
    
    public init(initial action: @escaping Action) {
        self.init([action])
    }
    
    public init() {
        self.init([])
    }
    
    public mutating func insert(_ action: @escaping Action) {
        value.append(action)
    }
    
    public func perform() {
        value.forEach({ $0() })
    }
}
