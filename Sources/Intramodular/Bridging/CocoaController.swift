//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_CocoaController {
    func present(
        _ presentation: CocoaPresentation,
        animated: Bool,
        completion: @escaping () -> ()
    )
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol CocoaController: opaque_CocoaController, UIViewController {
    func present(
        _ presentation: CocoaPresentation,
        animated: Bool,
        completion: @escaping () -> ()
    )
}

#elseif os(macOS)

public protocol CocoaController: opaque_CocoaController, NSViewController {
    func present(
        _ presentation: CocoaPresentation,
        animated: Bool,
        completion: @escaping () -> ()
    )
}

#endif
