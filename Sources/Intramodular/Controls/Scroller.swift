//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol Scroller: ViewInteractor {
    
}

// MARK: - Auxiliary Implementation -

public struct ScrollerEnvironmentKey: ViewInteractorEnvironmentKey {
    public typealias ViewInteractor = Scroller
}

extension EnvironmentValues {
    public var scroller: Scroller? {
        return self[ScrollerEnvironmentKey.self]
    }
}
