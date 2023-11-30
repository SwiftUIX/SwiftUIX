//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

@_spi(Internal)
extension NSScreen {
    public static var _primary: NSScreen? {
        assert(NSScreen.screens.count <= 1)
        
        return NSScreen.screens.first
    }
    
    /// <http://stackoverflow.com/a/19887161/23649>
    public func _convertToCocoaRect(
        quartzRect: CGRect
    ) -> CGRect {
        var result = quartzRect
        
        result.origin.y = self.frame.maxY - result.maxY
        
        return result
    }
    
    @_spi(Internal)
    public static func flip(
        _ point: CGPoint
    ) -> CGPoint {
        let globalHeight = screens.map({ $0.frame.origin.y + $0.frame.height }).max()!
        let flippedY = globalHeight - point.y
        let convertedPoint = NSPoint(x: point.x, y: flippedY)
        
        return convertedPoint
    }
    
    @_spi(Internal)
    public static func flip(
        _ rect: CGRect
    ) -> CGRect {
        CGRect(origin: flip(rect.origin), size: rect.size)
    }
}

@_spi(Internal)
extension NSWindow {
    public func flipLocal(
        _ point: CGPoint
    ) -> CGPoint {
        CGPoint(x: point.x, y: frame.height - point.y)
    }
    
    public func flipLocal(
        _ rect: CGRect
    ) -> CGRect {
        CGRect(
            x: rect.origin.x,
            y: frame.height - (rect.origin.y + rect.height),
            width: rect.width,
            height: rect.height
        )
    }
}

#endif
