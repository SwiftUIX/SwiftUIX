//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol HashIdentifiable: Hashable, Identifiable where Self.ID == Int {
    
}

extension HashIdentifiable {
    public var id: Int {
        hashValue
    }
}
