//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public extension UIHostingController {
    static func withCocoaPresentationSupport(rootView: Content) -> UIViewController {
        let coordinator = CocoaPresentationCoordinator()
        let viewController = UIHostingController<CocoaPresentationSupport<Content>>(
            rootView: .init(coordinator: coordinator, content: { rootView })
        )
        
        coordinator.viewController = viewController
        
        return viewController
    }
}

#endif
