//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// The orientation of a device.
public enum DeviceOrientation: CaseIterable, HashIdentifiable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case faceUp
    case faceDown
    
    case unrecognized
}

extension DeviceOrientation {
    public static var current: Self {
        #if os(iOS)
        return .init(UIDevice.current.orientation)
        #else
        return .portrait
        #endif
    }
    
    #if os(iOS)
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
    #endif
}
