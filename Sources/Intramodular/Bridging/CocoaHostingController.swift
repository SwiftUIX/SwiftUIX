//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<CocoaHostingControllerContent<Content>> {
    let presentation: CocoaPresentation?
    let presentationCoordinator: CocoaPresentationCoordinator?
    
    var _transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    public var rootViewContent: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    init(
        rootView: Content,
        presentation: CocoaPresentation?,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.presentation = presentation
        self.presentationCoordinator = presentationCoordinator
        
        super.init(
            rootView: CocoaHostingControllerContent(
                content: rootView,
                presentation: presentation,
                presentationCoordinator: presentationCoordinator
            )
        )
        
        presentationCoordinator.viewController = self
    }
    
    public convenience init(rootView: Content) {
        self.init(rootView: rootView, presentation: nil, presentationCoordinator: .init())
    }
        
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CocoaHostingController where Content == AnyView {
    convenience init(
        presentation: CocoaPresentation,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.init(
            rootView: presentation.content(),
            presentation: presentation,
            presentationCoordinator: presentationCoordinator
        )
        
        _transitioningDelegate = presentation.style.transitioningDelegate
        modalPresentationStyle = .init(presentation.style)
        transitioningDelegate = _transitioningDelegate
        view.backgroundColor = .clear
    }
}

#endif
