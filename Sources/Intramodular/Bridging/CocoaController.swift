//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol _opaque_CocoaController: AppKitOrUIKitViewController {
    func _namedViewDescription(for _: AnyHashable) -> _NamedViewDescription?
    func _setNamedViewDescription(_: _NamedViewDescription?, for _: AnyHashable)
}

public protocol CocoaController: _opaque_CocoaController {
    func _fixSafeAreaInsetsIfNecessary()
}

#endif
