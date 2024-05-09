//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public enum PopoverAttachmentTarget {
    case rect(_CoordinateSpaceRelative<CGRect>)
    
    public var _rectValue: _CoordinateSpaceRelative<CGRect>? {
        guard case .rect(let value) = self else {
            return nil
        }
        
        return value
    }
}

extension PopoverAttachmentTarget {
    public static func rect(
        _ rect: CGRect,
        in coordinateSpace: CoordinateSpace = .global
    ) -> Self {
        .rect(_CoordinateSpaceRelative(rect, in: .coordinateSpace(coordinateSpace)))
    }
    
    public static func cocoaRect(_ rect: CGRect, in screen: Screen) -> Self {
        .rect(_CoordinateSpaceRelative(rect, in: .cocoa(screen)))
    }
    
    public init?(
        _ proxy: IntrinsicGeometryProxy
    ) {
        guard let frame = proxy._frame(in: .global) else {
            return nil
        }
        
        self = .rect(frame, in: .global)
    }
}

extension PopoverAttachmentTarget {
    public var size: CGSize {
        switch self {
            case .rect(let rect):
                return rect.size
        }
    }
}

#if os(iOS) || os(macOS)
extension PopoverAttachmentTarget {
    public var _sourceAppKitOrUIKitWindow: AppKitOrUIKitWindow? {
        get {
            switch self {
                case .rect(let x):
                    return x._sourceAppKitOrUIKitWindow
            }
        } set {
            switch self {
                case .rect(var x):
                    x._sourceAppKitOrUIKitWindow = newValue
                    
                    self = .rect(x)
            }
        }
    }
}
#endif
