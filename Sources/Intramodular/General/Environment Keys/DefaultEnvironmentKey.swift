//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

open class DefaultEnvironmentKey<Value>: EnvironmentKey {
    public static var defaultValue: Value? {
        nil
    }
}
