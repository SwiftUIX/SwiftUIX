//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol CocoaViewController: AppKitOrUIKitViewController {
    func _namedViewDescription(for _: AnyHashable) -> _NamedViewDescription?
    func _setNamedViewDescription(_: _NamedViewDescription?, for _: AnyHashable)
    func _disableSafeAreaInsetsIfNecessary()
    
    func _SwiftUIX_sizeThatFits(in size: CGSize) -> CGSize
}

#endif
