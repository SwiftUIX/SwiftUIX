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
        if let viewController = viewController?.presentedViewController as? CocoaHostingController<AnyNamedOrUnnamedView>, viewController.modalViewPresentationStyle == presentation.style {
            viewController.rootViewContent = presentation.content()
            
            return
        }
        
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
}

// MARK: - Protocol Implementations -

extension CocoaPresentationCoordinator: DynamicViewPresenter {
    public var isPresented: Bool {
        return presentedCoordinator != nil
    }
    
    public func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)?,
        style: ModalViewPresentationStyle
    ) {
        present(CocoaPresentation(
            content: { view },
            shouldDismiss: { true },
            onDismiss: onDismiss,
            style: style
        ))
    }
    
    public func dismiss() {
        guard
            let viewController = viewController,
            let presentedCoordinator = presentedCoordinator,
            let presentation = presentedCoordinator.presentation,
            viewController.presentedViewController != nil,
            presentation.shouldDismiss() else {
                return
        }
        
        viewController.dismiss(animated: true) {
            presentation.onDismiss?()
            self.presentedCoordinator = nil
        }
    }
    
    public func dismiss(viewNamed name: ViewName) {
        var coordinator = self
        
        while let presentedCoordinator = coordinator.presentedCoordinator {
            if (presentedCoordinator.viewController as? CocoaHostingController<AnyNamedOrUnnamedView>)?.rootViewContentName == name {
                presentedCoordinator.dismissSelf()
            } else {
                coordinator = presentedCoordinator
            }
        }
    }
    
    public func dismissSelf() {
        presentingCoordinator?.dismiss()
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
        presentation?.onDismiss?()
    }
}

#endif
