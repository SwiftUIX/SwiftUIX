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

#if os(iOS)

extension UserInterfaceOrientation {
    public var current: UserInterfaceOrientation {
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
