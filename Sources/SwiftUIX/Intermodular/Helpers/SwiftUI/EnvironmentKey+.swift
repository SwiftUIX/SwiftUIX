//
// Copyright (c) Vatsal Manot
//

import SwiftUI

open class DefaultEnvironmentKey<Value>: EnvironmentKey {
    public static var defaultValue: Value? {
        nil
    }
}
