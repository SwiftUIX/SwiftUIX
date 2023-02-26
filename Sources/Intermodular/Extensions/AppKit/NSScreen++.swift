//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

extension NSScreen {
    /// <http://stackoverflow.com/a/19887161/23649>
    public func _convertToCocoaRect(
        quartzRect: CGRect
    ) -> CGRect {
        var result = quartzRect
        
        result.origin.y = self.frame.maxY - result.maxY
        
        return result
    }
}

#endif
