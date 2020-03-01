//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

class CocoaAlignHostingPresentationController<Background: View, Content: View>: UIPresentationController {
    struct BackgroundContainer: View {
        let content: Background
        
        var presentationCoordinator: CocoaPresentationCoordinator?
        var transitionType: PresentationTransitionType?
        
        var body: some View {
            CocoaHostingControllerContent(
                content: content
                    .environment(\.presentationTransitionType, transitionType),
                presentationCoordinator: presentationCoordinator
            )
        }
    }
    
    let background: Background
    let source: Alignment
    let destination: Alignment
    
    var _backgroundHostingView: CocoaHostingView<BackgroundContainer>?
    
    var backgroundHostingView: CocoaHostingView<BackgroundContainer> {
        _backgroundHostingView ?? CocoaHostingView<BackgroundContainer>(rootView: .init(content: background)).then {
            $0.frame = .init(
                origin: .zero,
                size: containerView!.bounds.size
            )
            
            _backgroundHostingView = $0
        }
    }
    
    var dismissalInteractionController: CocoaAlignModalTransition
    
    var _presentedViewController: AppKitOrUIKitHostingControllerProtocol {
        presentedViewController as! AppKitOrUIKitHostingControllerProtocol
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerSize = containerView!.frame.size
        
        return .init(
            size: _presentedViewController.sizeThatFits(in: containerSize),
            container: containerSize,
            alignment: destination,
            inside: true
        )
    }
    
    public init(
        presented: UIViewController,
        presenting presentingViewController: UIViewController?,
        background: Background,
        source: Alignment,
        destination: Alignment,
        dismissalInteractionController: CocoaAlignModalTransition
    ) {
        self.background = background
        self.source = source
        self.destination = destination
        self.dismissalInteractionController = dismissalInteractionController
        
        super.init(
            presentedViewController: presented,
            presenting: presentingViewController
        )
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        let backgroundHostingView = self.backgroundHostingView
        
        if let containerView = containerView {
            containerView.addSubview(backgroundHostingView)
            
            backgroundHostingView.rootView.presentationCoordinator = presentedViewController.presentationCoordinator
            backgroundHostingView.addSubview(presentedViewController.view)
        }
        
        backgroundHostingView.rootView.transitionType = .presentationWillBegin
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        backgroundHostingView.rootView.transitionType = .presentationDidEnd
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        delegate?.presentationControllerWillDismiss?(self)
        
        backgroundHostingView.rootView.transitionType = .dismissalWillBegin
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        if completed {
            delegate?.presentationControllerDidDismiss?(self)
            
            backgroundHostingView.rootView.presentationCoordinator = nil
            backgroundHostingView.rootView.transitionType = .dismissalDidEnd
            backgroundHostingView.removeFromSuperview()
            
            _backgroundHostingView = nil
        }
    }
}

#endif
