//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class CocoaPresentationCoordinator: NSObject, UIAdaptivePresentationControllerDelegate {
    private var presentation: CocoaPresentation?
    private var transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    private weak var presentingCoordinator: CocoaPresentationCoordinator?
    
    var onDidAttemptToDismiss: [CocoaPresentation.DidAttemptToDismissCallback] = []
    
    weak var viewController: UIViewController? {
        didSet {
            viewController?.presentationController?.delegate = self
        }
    }
    
    var presentedCoordinator: CocoaPresentationCoordinator?
    
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
    
    func present(presentation: CocoaPresentation) {
        if let presentation = presentedCoordinator?.presentation {
            guard presentation.shouldDismiss() else {
                return
            }
            
            presentedCoordinator?.dismiss()
        }
        
        let coordinator = CocoaPresentationCoordinator(presentation: presentation, presentingCoordinator: self)
        
        let rootView =
            _CocoaPresentationView(coordinator: coordinator) {
                presentation.content()
        }
        
        let viewController = UIHostingController(rootView: rootView)
        
        viewController.modalPresentationStyle = .init(presentation.presentationStyle)
        viewController.view.backgroundColor = .clear
        viewController.transitioningDelegate = presentation.presentationStyle.transitioningDelegate
        
        coordinator.viewController = viewController
        
        presentedCoordinator = coordinator
        
        self.viewController?.present(viewController, animated: true)
    }
    
    func dismiss() {
        guard let presentingCoordinator = presentingCoordinator, presentingCoordinator.presentedCoordinator === self else {
            return
        }
        
        presentingCoordinator.dismissPresentedView()
    }
    
    func dismissPresentedView() {
        guard let presentedCoordinator = presentedCoordinator, let presentation = presentedCoordinator.presentation else {
            return
        }
        
        if let viewController = presentedCoordinator.viewController {
            presentedCoordinator.viewController = nil
            viewController.dismiss(animated: true)
        }
        
        self.presentedCoordinator = nil
        
        if !presentation.shouldDismiss() {
            presentation.resetBinding()
        }
        
        presentation.onDismiss?()
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        for callback in onDidAttemptToDismiss {
            callback.action()
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewController = nil
        dismiss()
    }
}

#endif
