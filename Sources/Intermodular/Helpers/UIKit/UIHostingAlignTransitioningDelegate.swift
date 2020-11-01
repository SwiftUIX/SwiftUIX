//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

class UIHostingAlignTransitioningDelegate<Background: View, Content: View>: UIHostingControllerTransitioningDelegate<Content> {
    let background: Background
    let source: Alignment
    let destination: Alignment
    
    let dismissalInteractionController = UIHostingAlignModalTransition()
    
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
        UIHostingAlignTransitionAnimator(
            source: self.source,
            destination: self.destination,
            isPresenting: true
        )
    }
    
    override func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        UIHostingAlignTransitionAnimator(
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
        UIHostingAlignPresentationController<Background, Content>(
            presented: presented,
            presenting: presenting,
            background: background,
            source: self.source,
            destination: self.destination,
            dismissalInteractionController: dismissalInteractionController
        )
    }
}

// MARK: - API -

extension ModalPresentationStyle {
    public static func align(
        source: Alignment = .bottom,
        destination: Alignment
    ) -> Self {
        .custom(
            UIHostingAlignTransitioningDelegate(
                background: DefaultPresentationBackdrop(),
                source: source,
                destination: destination,
                contentType: AnyPresentationView.self
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
