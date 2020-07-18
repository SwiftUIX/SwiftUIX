//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct StatusItemGroup<ID, Items> {
    public let items: Items
    
    public init(_ items: Items) {
        self.items = items
    }
}
