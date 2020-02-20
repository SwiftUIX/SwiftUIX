//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

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
