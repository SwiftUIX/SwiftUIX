//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class CocoaPresentationCoordinator: NSObject {
    private let presentation: CocoaPresentation?
    
    private weak var presentingCoordinator: CocoaPresentationCoordinator?
    
    var onDidAttemptToDismiss: [CocoaPresentation.DidAttemptToDismissCallback] = []
    var presentedCoordinator: CocoaPresentationCoordinator?
    var transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    weak var viewController: UIViewController?
    
    override init() {
        self.presentation = nil
        self.presentingCoordinator = nil
    }
    
    init(
        presentation: CocoaPresentation? = nil,
        presentingCoordinator: CocoaPresentationCoordinator? = nil
    ) {
        self.presentation = presentation
        self.presentingCoordinator = presentingCoordinator
    }
    
    func present(_ presentation: CocoaPresentation) {
        if let viewController = viewController?.presentedViewController as? CocoaHostingController<AnyView>, viewController.modalViewPresentationStyle == presentation.style {
            viewController.rootViewContent = presentation.content()
            
            return
        }
        
        presentedCoordinator?.dismissSelf()
        
        let presentationCoordinator = CocoaPresentationCoordinator(
            presentation: presentation,
            presentingCoordinator: self
        )
        
        let viewControllerToBePresented = CocoaHostingController(
            presentation: presentation,
            presentationCoordinator: presentationCoordinator
        )
        
        presentedCoordinator = presentationCoordinator
        
        viewControllerToBePresented.presentationController?.delegate = presentationCoordinator
        
        self.viewController?.present(
            viewControllerToBePresented,
            animated: true,
            completion: nil
        )
    }
    
    func dismissSelf() {
        guard let presentation = presentation, presentation.shouldDismiss() else {
            return
        }
        
        guard let presentingCoordinator = presentingCoordinator, presentingCoordinator.presentedCoordinator === self else {
            return
        }
        
        presentingCoordinator.dismissPresentedView()
    }
    
    func dismissPresentedView() {
        guard let presentedCoordinator = presentedCoordinator, let presentation = presentedCoordinator.presentation else {
            return
        }
        
        presentedCoordinator.viewController?.dismiss(animated: true)
        presentedCoordinator.viewController = nil
        
        self.presentedCoordinator = nil
        
        if !presentation.shouldDismiss() {
            presentation.resetBinding()
        }
        
        presentation.onDismiss?()
    }
}

// MARK: - Protocol Implementations -

extension CocoaPresentationCoordinator: DynamicViewPresenter {
    public func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)?,
        style: ModalViewPresentationStyle
    ) {
        present(CocoaPresentation(
            content: { view.eraseToAnyView() },
            onDismiss: onDismiss,
            shouldDismiss: { true },
            resetBinding: { },
            style: style
        ))
    }
}

extension CocoaPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if let presentation = presentation {
            return .init(presentation.style)
        } else {
            return .automatic
        }
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        presentation?.shouldDismiss() ?? true
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        for callback in onDidAttemptToDismiss {
            callback.action()
        }
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissSelf()
    }
}

#endif

