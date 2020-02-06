//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

class CocoaAlignHostingTransitioningDelegate<Content: View>: CocoaHostingControllerTransitioningDelegate<Content> {
    let source: Alignment
    let destination: Alignment
    
    let dismissalInteractionController = CocoaAlignModalTransition()
    
    init(source: Alignment, destination: Alignment) {
        self.source = source
        self.destination = destination
    }
    
    override func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        CocoaAlignHostingTransitionAnimator(
            source: self.source,
            destination: self.destination,
            isPresenting: true
        )
    }

    override func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        CocoaAlignHostingTransitionAnimator(
            source: self.source,
            destination: self.destination,
            isPresenting: false
        )
    }
    
    override func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        dismissalInteractionController
    }
    
    override func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        CocoaAlignHostingPresentationController<Content>(
            presented: presented,
            presenting: presenting,
            source: self.source,
            destination: self.destination,
            dismissalInteractionController: dismissalInteractionController
        )
    }
}

// MARK: - Helpers -

extension ModalViewPresentationStyle {
    public static func align(
        source: Alignment,
        destination: Alignment
    ) -> Self {
        .custom(CocoaAlignHostingTransitioningDelegate<EnvironmentalAnyView>(source: source, destination: destination))
    }
    
    public static func align(
        source: Alignment
    ) -> Self {
        .align(source: source, destination: source)
    }
}

#endif
