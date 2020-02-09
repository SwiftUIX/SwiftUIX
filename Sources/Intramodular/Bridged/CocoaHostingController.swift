//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<CocoaHostingControllerContent<Content>> {
    public let presentationCoordinator: CocoaPresentationCoordinator
    
    public var rootViewContent: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    init(
        rootView: Content,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.presentationCoordinator = presentationCoordinator
        
        super.init(rootView: .init(content: rootView))
        
        presentationCoordinator.viewController = self
    }
    
    public convenience init(rootView: Content) {
        self.init(rootView: rootView, presentationCoordinator: .init(parent: nil))
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        presentationCoordinator.presentingCoordinator = parent?.objc_associated_presentationCoordinator
    }
}

#endif
