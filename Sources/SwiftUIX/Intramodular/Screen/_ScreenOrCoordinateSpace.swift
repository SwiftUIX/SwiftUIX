//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)

/// An enumeration that represents either a screen or a SwiftUI `CoordinateSpace`.
@_documentation(visibility: internal)
public enum _ScreenOrCoordinateSpace: Hashable, @unchecked Sendable {
    case cocoa(Screen?)
    case coordinateSpace(CoordinateSpace)
    
    public var _cocoaScreen: Screen? {
        guard case .cocoa(let screen) = self else {
            return nil
        }
        
        return screen
    }
}

#if os(macOS)
extension _ScreenOrCoordinateSpace {
    public static func cocoa(
        _ screen: NSScreen?
    ) -> Self {
        Self.cocoa(screen.map({ Screen($0) }))
    }
}
#endif

extension _ScreenOrCoordinateSpace {
    public static var local: Self {
        .coordinateSpace(.local)
    }
    
    public static var global: Self {
        .coordinateSpace(.global)
    }
}

#endif
