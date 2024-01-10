//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

class UIHostingAlignTransitioningDelegate<Background: View, Content: View>: UIHostingControllerTransitioningDelegate<Content> {
    private let background: Background
    private let source: Alignment
    private let destination: Alignment
    
    private let dismissalInteractionController = Transition()
    
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
        Transition.Animator(
            source: self.source,
            destination: self.destination,
            isPresenting: true
        )
    }
    
    override func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        Transition.Animator(
            source: self.source,
            destination: self.destination,
            isPresenting: false
        )
    }
    
    override func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        dismissalInteractionController
    }
    
    override func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        PresentationController(
            presented: presented,
            presenting: presenting,
            background: background,
            source: self.source,
            destination: self.destination,
            dismissalInteractionController: dismissalInteractionController
        )
    }
}

// MARK: - API

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
    
    private struct DefaultPresentationBackdrop: View {
        @Environment(\.presentationManager) var presentationManager
        @Environment(\._presentationTransitionPhase) var transitionPhase
        
        @State private var viewDidAppear = false
        
        private var opacity: Double {
            guard let transitionPhase = transitionPhase else {
                return 0.0
            }
            
            switch transitionPhase {
                case .willDismiss:
                    return 0.0
                case .didDismiss:
                    return 0.0
                default:
                    break
            }
            
            if viewDidAppear {
                return 0.3
            } else {
                return 0.0
            }
        }
        
        var body: some View {
            Color.black
                .opacity(opacity)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation {
                        self.viewDidAppear = true
                    }
                }
                .modify { content in
                    #if !os(tvOS)
                    content.onTapGesture(perform: dismiss)
                    #else
                    content
                    #endif
                }
        }
        
        func dismiss() {
            presentationManager.dismiss()
        }
    }
}

extension UIHostingAlignTransitioningDelegate {
    fileprivate class Transition: UIPercentDrivenInteractiveTransition {
        override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
            super.wantsInteractiveStart = false
            
            super.startInteractiveTransition(transitionContext)
        }
    }
}

extension UIHostingAlignTransitioningDelegate.Transition {
    fileprivate class Animator: NSObject, UIViewControllerAnimatedTransitioning {
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
}

extension UIHostingAlignTransitioningDelegate {
    fileprivate class PresentationController: UIPresentationController {
        struct BackgroundContainer: View {
            let content: Background
            
            weak var parent: CocoaViewController?
            
            var presentationCoordinator: CocoaPresentationCoordinator?
            var transitionType: PresentationTransitionPhase?
            
            var body: some View {
                CocoaHostingControllerContent(
                    parent: parent,
                    parentConfiguration: .init(),
                    content: content
                        .environment(\._presentationTransitionPhase, transitionType)
                )
            }
        }
        
        let background: Background
        let source: Alignment
        let destination: Alignment
        
        var _backgroundHostingView: UIHostingView<BackgroundContainer>?
        
        var backgroundHostingView: UIHostingView<BackgroundContainer> {
            _backgroundHostingView ?? UIHostingView<BackgroundContainer>(rootView: .init(content: background)).then {
                $0.frame = .init(
                    origin: .zero,
                    size: containerView!.bounds.size
                )
                
                _backgroundHostingView = $0
            }
        }
        
        var dismissalInteractionController: Transition
        
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
            dismissalInteractionController: Transition
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
            
            backgroundHostingView.rootView.transitionType = .willBegin
        }
        
        override func presentationTransitionDidEnd(_ completed: Bool) {
            super.presentationTransitionDidEnd(completed)
            
            backgroundHostingView.rootView.transitionType = .didEnd
        }
        
        override func dismissalTransitionWillBegin() {
            super.dismissalTransitionWillBegin()
            
            delegate?.presentationControllerWillDismiss?(self)
            
            backgroundHostingView.rootView.transitionType = .willDismiss
        }
        
        override func dismissalTransitionDidEnd(_ completed: Bool) {
            super.dismissalTransitionDidEnd(completed)
            
            if completed {
                delegate?.presentationControllerDidDismiss?(self)
                
                backgroundHostingView.rootView.presentationCoordinator = nil
                backgroundHostingView.rootView.transitionType = .didDismiss
                backgroundHostingView.removeFromSuperview()
                
                _backgroundHostingView = nil
            }
        }
    }
}

#endif
