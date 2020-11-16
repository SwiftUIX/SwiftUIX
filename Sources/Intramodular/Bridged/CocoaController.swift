//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol _opaque_CocoaController: AppKitOrUIKitViewController {
    
}

public protocol CocoaController: _opaque_CocoaController {
    func _namedViewDescription(for _: ViewName) -> _NamedViewDescription?
}

#endif
