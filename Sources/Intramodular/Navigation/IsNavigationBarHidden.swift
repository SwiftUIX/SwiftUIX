//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

final class IsNavigationBarHidden: DefaultEnvironmentKey<Bool> {
    
}

extension EnvironmentValues {
    public var isNavigationBarHidden: Bool? {
        get {
            self[IsNavigationBarHidden]
        } set {
            self[IsNavigationBarHidden] = newValue
        }
    }
}
