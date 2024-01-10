//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)
/*extension NSView {
    private struct AssociatedKeys {
        static var debugBackgroundView: Void = ()
    }
    
    public var _SwiftUIX_debugBackgroundView: NSView {
        get {
            if let bgView = objc_getAssociatedObject(self, &AssociatedKeys.debugBackgroundView) as? NSView {
                return bgView
            }
            
            let newView = NSView(frame: self.bounds)
            
            newView.autoresizingMask = [.width, .height]
            newView.wantsLayer = true
            
            self.addSubview(newView, positioned: .below, relativeTo: self.subviews.first)
            
            objc_setAssociatedObject(self, &AssociatedKeys.debugBackgroundView, newView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return newView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.debugBackgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func _SwiftUIX_setDebugBackgroundColor(_ color: NSColor) {
        DispatchQueue.main.async {
            self._SwiftUIX_debugBackgroundView.layer?.backgroundColor = color.cgColor
        }
    }
}*/
#endif
