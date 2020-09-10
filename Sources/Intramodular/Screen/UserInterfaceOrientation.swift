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

#if os(iOS)

extension UserInterfaceOrientation {
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public static var current: UserInterfaceOrientation {
        guard let orientation = UIApplication.shared.firstKeyWindow?.windowScene?.interfaceOrientation else {
            return .portrait
        }
        
        return .init(orientation)
    }
    
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
}

#endif
