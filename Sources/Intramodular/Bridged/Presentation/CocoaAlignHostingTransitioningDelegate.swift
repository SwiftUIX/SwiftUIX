//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

class CocoaAlignHostingTransitioningDelegate<Background: View, Content: View>: CocoaHostingControllerTransitioningDelegate<Content> {
    let background: Background
    let source: Alignment
    let destination: Alignment
    
    let dismissalInteractionController = CocoaAlignModalTransition()
    
    init(
        background: Background,
        source: Alignment,
        destination: Alignment,
        contentType: Content.Type = Content.self
    ) {
        self.background = background
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
        CocoaAlignHostingPresentationController<Background, Content>(
            presented: presented,
            presenting: presenting,
            background: background,
            source: self.source,
            destination: self.destination,
            dismissalInteractionController: dismissalInteractionController
        )
    }
}

// MARK: - Helpers -

extension ModalViewPresentationStyle {
    public static func align(
        source: Alignment = .bottom,
        destination: Alignment
    ) -> Self {
        .custom(
            CocoaAlignHostingTransitioningDelegate(
                background: DefaultPresentationBackdrop(),
                source: source,
                destination: destination,
                contentType: EnvironmentalAnyView.self
            )
        )
    }
    
    public static func align(
        source: Alignment
    ) -> Self {
        .align(source: source, destination: source)
    }
}

#endif
