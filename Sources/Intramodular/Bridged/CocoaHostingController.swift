//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<CocoaHostingControllerContent<Content>>, CocoaController {
    public let _presentationCoordinator: CocoaPresentationCoordinator
    
    public override var presentationCoordinator: CocoaPresentationCoordinator {
        return _presentationCoordinator
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
        self._presentationCoordinator = presentationCoordinator
        
        super.init(rootView: .init(content: rootView, presentationCoordinator: presentationCoordinator))
        
        presentationCoordinator.setViewController(self)
        
        if let rootView = rootView as? EnvironmentalAnyView {
            #if os(iOS) || targetEnvironment(macCatalyst)
            hidesBottomBarWhenPushed = rootView.hidesBottomBarWhenPushed
            #endif
            isModalInPresentation = !rootView.isModalDismissable
            modalPresentationStyle = .init(rootView.presentationStyle)
            transitioningDelegate = rootView.presentationStyle.transitioningDelegate
            
            environmentBuilder.merge(rootView.presentationEnvironmentBuilder)
        }
    }
    
    public convenience init(rootView: Content) {
        self.init(rootView: rootView, presentationCoordinator: .init())
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
