//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

extension NSView {
    public static var layoutFittingCompressedSize: CGSize {
        .init(width: 0, height: 0)
    }
    
    public static var layoutFittingExpandedSize: CGSize {
        .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude) // FIXME
    }
    
    @objc open func hitTest(_ point: CGPoint, with event: NSEvent?) -> NSView? {
        hitTest(point)
    }
}

#endif
