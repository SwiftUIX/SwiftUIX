//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<CocoaHostingControllerContent<Content>>, CocoaController {
    public let presentationCoordinator: CocoaPresentationCoordinator
    
    public var rootViewName: ViewName? {
        (rootView as? opaque_NamedView)?.name
    }
    
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
        
        super.init(rootView: .init(content: rootView, presentationCoordinator: presentationCoordinator))
        
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
}

#endif
