//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

class CocoaAlignHostingPresentationController<Content: View>: UIPresentationController {
    let source: Alignment
    let destination: Alignment
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
        source: Alignment,
        destination: Alignment,
        dismissalInteractionController: CocoaAlignModalTransition
    ) {
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
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        delegate?.presentationControllerWillDismiss?(self)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        if completed {
            delegate?.presentationControllerDidDismiss?(self)
        }
    }
}

#endif
