//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    @inlinable
    public func environment(_ newEnvironment: EnvironmentValues) -> some View {
        transformEnvironment(\.self) { environment in
            environment = newEnvironment
        }
    }
    
    @inlinable
    public func environment(_ newEnvironment: EnvironmentValues?) -> some View {
        Group {
            if newEnvironment != nil {
                environment(newEnvironment!)
            } else {
                self
            }
        }
    }
}
