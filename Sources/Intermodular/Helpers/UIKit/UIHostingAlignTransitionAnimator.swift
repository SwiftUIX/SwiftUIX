//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import QuartzCore
import Swift
import SwiftUI
import UIKit

class UIHostingAlignTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let source: Alignment
    let destination: Alignment
    let isPresenting: Bool
    
    init(source: Alignment, destination: Alignment, isPresenting: Bool) {
        self.source = source
        self.destination = destination
        self.isPresenting = isPresenting
    }
    
    @objc func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let containerView = transitionContext.containerView
        
        let from = transitionContext.viewController(forKey: .from)!
        let to = transitionContext.viewController(forKey: .to)!
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
        if isPresenting {
            let toSize = (to as? AppKitOrUIKitHostingControllerProtocol)?.sizeThatFits(in: containerView.frame.size) ?? to.view.sizeThatFits(containerView.frame.size)
            
            let fromFrame = CGRect(
                size: toSize,
                container: containerView.frame.size,
                alignment: source,
                inside: false
            )
            
            let toFrame = CGRect(
                size: toSize,
                container: containerView.frame.size,
                alignment: destination,
                inside: true
            )
            
            to.view.frame = fromFrame
            
            UIView.animate(withDuration: transitionDuration, animations: {
                to.view.frame = toFrame
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            let toFrame = CGRect(
                size: from.view.frame.size,
                container: containerView.frame.size,
                alignment: source,
                inside: false
            )
            
            UIView.animate(withDuration: transitionDuration, animations: {
                from.view.frame = toFrame
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
}

#endif
