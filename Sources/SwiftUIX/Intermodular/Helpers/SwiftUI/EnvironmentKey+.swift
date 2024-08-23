//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
open class DefaultEnvironmentKey<Value>: EnvironmentKey {
    public static var defaultValue: Value? {
        nil
    }
}
