//
// Copyright (c) Vatsal Manot
//

import SwiftUI

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
}
#endif
