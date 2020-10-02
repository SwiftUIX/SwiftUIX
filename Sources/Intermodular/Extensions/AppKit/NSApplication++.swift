//
// Copyright (c) Vatsal Manot
//

#if os(macOS) || targetEnvironment(macCatalyst)

import AppKit
import Swift
import SwiftUI

@available(macCatalyst, unavailable)
extension NSApplication {
    public var firstKeyWindow: NSWindow? {
        keyWindow
    }
}

#endif
