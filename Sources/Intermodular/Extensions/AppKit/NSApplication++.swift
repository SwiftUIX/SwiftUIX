//
//  NSApplication++.swift
//  
//
//  Created by Siddarth on 6/9/20.
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

extension NSApplication {
    public var firstKeyWindow: NSWindow? {
        windows.first(where: { $0.isKeyWindow })
    }
}

#endif
