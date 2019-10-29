//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

extension NSUserInterfaceLayoutDirection {
    public init(_ layoutDirection: LayoutDirection) {
        switch layoutDirection {
            case .leftToRight:
                self = .leftToRight
            case .rightToLeft:
                self = .rightToLeft
            @unknown default:
                fatalError()
        }
    }
}

#endif
