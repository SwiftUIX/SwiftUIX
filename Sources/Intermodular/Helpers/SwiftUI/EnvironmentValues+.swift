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
}
