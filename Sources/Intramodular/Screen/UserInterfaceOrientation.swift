//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// The orientation of the app's user interface.
public enum UserInterfaceOrientation {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    
    case unrecognized
}

extension UserInterfaceOrientation {
    public var isPortrait: Bool {
        switch self {
            case .portrait, .portraitUpsideDown:
                return true
            default:
                return false
        }
    }
    
    public var isLandscape: Bool {
        switch self {
            case .landscapeLeft, .landscapeRight:
                return true
            default:
                return false
        }
    }
}

extension UserInterfaceOrientation {
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    public static var current: UserInterfaceOrientation {
        #if os(iOS)
        guard let orientation = UIApplication.shared.firstKeyWindow?.windowScene?.interfaceOrientation else {
            return .portrait
        }
        
        return .init(orientation)
        #else
        return .portrait
        #endif
    }
    
    #if os(iOS)
    public init(_ orientation: UIInterfaceOrientation) {
        switch orientation {
            case .portrait:
                self = .portrait
            case .portraitUpsideDown:
                self = .portraitUpsideDown
            case .landscapeLeft:
                self = .landscapeLeft
            case .landscapeRight:
                self = .landscapeRight
            case .unknown:
                self = .unrecognized
            @unknown default:
                self = .unrecognized
        }
    }
    #endif
}

// MARK: - Auxiliary Implementation -

#if os(iOS)

extension UIInterfaceOrientation {
    public init(_ orientation: UserInterfaceOrientation) {
        switch orientation {
            case .portrait:
                self = .portrait
            case .portraitUpsideDown:
                self = .portraitUpsideDown
            case .landscapeLeft:
                self = .landscapeLeft
            case .landscapeRight:
                self = .landscapeRight
            case .unrecognized:
                self = .unknown
        }
    }
}

extension UIInterfaceOrientationMask {
    public init(_ orientation: UserInterfaceOrientation) {
        switch orientation {
            case .portrait:
                self = .portrait
            case .portraitUpsideDown:
                self = .portraitUpsideDown
            case .landscapeLeft:
                self = .landscapeLeft
            case .landscapeRight:
                self = .landscapeRight
            default:
                self = []
        }
    }
    
    public init(_ orientations: [UserInterfaceOrientation]) {
        self = orientations.map({ UIInterfaceOrientationMask($0) }).reduce(into: [], { $0.formUnion($1) })
    }
}

#endif
