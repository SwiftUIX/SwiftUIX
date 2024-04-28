//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

extension NSFont {
    @available(macOS 11.0, *)
    public static func preferredFont(forTextStyle textStyle: TextStyle) -> NSFont {
        .preferredFont(forTextStyle: textStyle, options: [:])
    }
}

#endif
