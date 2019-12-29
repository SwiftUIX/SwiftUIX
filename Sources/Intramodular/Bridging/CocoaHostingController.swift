//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<AnyView> {
    let coordinator = CocoaPresentationCoordinator()

    public init(rootView: Content) {
        super.init(
            rootView: _CocoaPresentationView(coordinator: coordinator) {
                rootView
            }.eraseToAnyView()
        )
        
        coordinator.viewController = self
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: {
            completion?()
            self.coordinator.presentedCoordinator?.dismissSelf()
        })
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
