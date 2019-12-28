//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class CocoaPresentationCoordinator: NSObject {
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
    
    func present(_ presentation: CocoaPresentation) {
        presentedCoordinator?.dismissSelf()
        
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
        presentationStyle: ModalViewPresentationStyle
    ) {
        present(CocoaPresentation(
            content: { view.eraseToAnyView() },
            onDismiss: onDismiss,
            shouldDismiss: { true },
            resetBinding: { },
            presentationStyle: presentationStyle
        ))
    }
}

extension CocoaPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        for callback in onDidAttemptToDismiss {
            callback.action()
        }
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        presentation?.shouldDismiss() ?? true
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissSelf()
    }
}

#endif

