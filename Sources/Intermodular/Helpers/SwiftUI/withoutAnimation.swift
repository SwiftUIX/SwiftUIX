//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public func withoutAnimation(_ body: () -> ()) {
    withAnimation(.none) {
        body()
    }
}
