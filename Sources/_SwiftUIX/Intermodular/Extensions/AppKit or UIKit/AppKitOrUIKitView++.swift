//
// Copyright (c) Vatsal Manot
//

#if os(macOS)
import AppKit
#endif
import QuartzCore
import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(iOS) || os(tvOS) || os(visionOS)
extension UIView {
    public var _SwiftUIX_firstLayer: CALayer? {
        get {
            layer.sublayers?.first
        } set {
            guard let newValue else {
                assertionFailure()
                
                return
            }
            
            layer.insertSublayer(newValue, at: 0)
        }
    }
    
    public var _SwiftUIX_backgroundColor: AppKitOrUIKitColor? {
        get {
            layer.backgroundColor.map(AppKitOrUIKitColor.init)
        } set {
            layer.backgroundColor = newValue?.cgColor
        }
    }
}
#elseif os(macOS)
extension NSView {
    public var _SwiftUIX_firstLayer: CALayer? {
        get {
            layer
        } set {
            layer = newValue
        }
    }
    
    public var _SwiftUIX_backgroundColor: NSColor? {
        get {
            // NSView doesn't naturally support backgroundColor
            // We can try to get it from the layer if it exists
            guard let layer: CALayer = layer else {
                return nil
            }
            
            return layer.backgroundColor.flatMap({ NSColor(cgColor: $0) })
        } set {
            // Ensure layer-backing is enabled
            guard wantsLayer else {
                assertionFailure("Attempted to set backgroundColor on non-layer-backed NSView")
                return
            }
            
            // Create layer if needed
            if layer == nil {
                layer = CALayer()
            }
            
            // Set the background color
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}
#endif
