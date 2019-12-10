//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<AnyView> {
    public init(rootView: Content) {
        let coordinator = CocoaPresentationCoordinator()
        
        super.init(
            rootView: CocoaPresentationSupport(coordinator: coordinator) {
                rootView
            }.eraseToAnyView()
        )
        
        coordinator.viewController = self
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
