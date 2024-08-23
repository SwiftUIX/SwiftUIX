//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// The orientation of a device.
@_documentation(visibility: internal)
public enum DeviceOrientation: CaseIterable, _HashIdentifiable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case faceUp
    case faceDown
    
    case unrecognized
}

extension DeviceOrientation {
    #if os(iOS) 
    public static var current: Self {
        get {
            .portrait
        } set {
            guard newValue != current else {
                return
            }
            
            guard let orientation = UIDeviceOrientation(newValue) else {
                assertionFailure("Attempting to set an unrecognized orientation.")
                return
            }
            
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    #else
    public static var current: Self {
        .portrait
    }
    #endif
    
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

// MARK: - Auxiliary

#if os(iOS)
extension UIDeviceOrientation {
    public init?(_ orientation: DeviceOrientation) {
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
                
            case .unrecognized:
                return nil
        }
    }
}

#endif
