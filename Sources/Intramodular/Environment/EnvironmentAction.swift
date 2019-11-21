//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct EnvironmentAction {
    private let value: () -> ()
    
    public init(_ value: @escaping () -> ()) {
        self.value = value
    }
    
    public func run() {
        value()
    }
}
