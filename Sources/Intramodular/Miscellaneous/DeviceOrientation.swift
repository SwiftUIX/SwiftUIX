//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// The orientation of a device.
public enum DeviceOrientation {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case faceUp
    case faceDown
    
    case unrecognized
}

#if canImport(UIKit)

extension DeviceOrientation {
    public static var current: Self {
        .init(UIDevice.current.orientation)
    }
    
    public init(_ orientation: UIDeviceOrientation) {
        switch orientation {
            case .portrait:
                self = .portrait
            case .portraitUpsideDown:
                self = .portraitUpsideDown
            case .landscapeLeft:
                self = .landscapeLeft
            case .landscapeRight:
                self = .landscapeRight
            case .faceUp:
                self = .faceUp
            case .faceDown:
                self = .faceDown
            case .unknown:
                self = .unrecognized
            @unknown default:
                self = .unrecognized
        }
    }
}
#endif
