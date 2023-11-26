//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Never {
    static func produce() -> Never {
        Swift.fatalError()
    }
    
    static func produce<T>(from _: T) -> Never {
        Swift.fatalError()
    }
}

#if swift(<5.5)
extension Never: Identifiable {
    public var id: Never {
        Self.produce()
    }
}
#endif
