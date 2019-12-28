//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct DefaultEnvironmentKey<Value>: EnvironmentKey {
    public static var defaultValue: Value? {
        nil
    }
}
