//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Never {
    public static func _SwiftUIX_produce() -> Never {
        Swift.fatalError()
    }
    
    public static func _SwiftUIX_produce<T>(from _: T) -> Never {
        Swift.fatalError()
    }
}

#if swift(<5.5)
extension Never: Identifiable {
    public var id: Never {
        Self._SwiftUIX_produce()
    }
}
#endif
