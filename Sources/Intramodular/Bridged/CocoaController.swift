//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol opaque_CocoaController: AppKitOrUIKitViewController {
    
}

public protocol CocoaController: opaque_CocoaController {
    func description(for _: ViewName) -> ViewDescription?
}

#endif
