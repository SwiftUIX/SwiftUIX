//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public final class MutableHeapWrapper<T> {
    public var value: T
    
    @inlinable
    public init(_ value: T) {
        self.value = value
    }
}
