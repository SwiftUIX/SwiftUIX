//
// Copyright (c) Vatsal Manot
//

#if os(macOS) || targetEnvironment(macCatalyst)

import AppKit
import Swift
import SwiftUI

extension NSToolbar {
    public func setItems(_ newItems: [NSToolbarItem]) {
        for _ in 0..<items.count {
            removeItem(at: 0)
        }
        
        for item in newItems.reversed() {
            insertItem(withItemIdentifier: item.itemIdentifier, at: 0)
        }
    }
}

#endif
