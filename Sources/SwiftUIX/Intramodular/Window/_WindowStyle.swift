//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public enum _WindowStyle: Sendable {
    case `default`
    case hiddenTitleBar
    case plain
    case titleBar
    case _transparent
    
    @available(macOS 11.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(from windowStyle: any WindowStyle) {
        switch windowStyle {
            case is DefaultWindowStyle:
                self = .`default`
            case is HiddenTitleBarWindowStyle:
                self = .hiddenTitleBar
            case is TitleBarWindowStyle:
                self = .titleBar
            default:
                assertionFailure("unimplemented")
                
                self = .default
        }
    }
}

#endif
