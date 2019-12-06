//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol Navigator {
    func push<V: View>(_: V)
    func pop()
}

// MARK: - Helpers -

struct NavigatorEnvironmentKey: EnvironmentKey {
    static var defaultValue: Navigator? {
        return nil
    }
}

extension EnvironmentValues {
    public var navigator: Navigator? {
        get {
            self[NavigatorEnvironmentKey.self]
        } set {
            self[NavigatorEnvironmentKey.self] = newValue
        }
    }
}
