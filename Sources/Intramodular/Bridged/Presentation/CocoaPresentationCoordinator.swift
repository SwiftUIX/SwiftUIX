//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class CocoaPresentationCoordinator: NSObject {
    private let presentation: AnyModalPresentation?
    
    public var presentingCoordinator: CocoaPresentationCoordinator? {
        if let presentingViewController = viewController.presentingViewController {
            return presentingViewController.runtimePresentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(before: viewController)?.runtimePresentationCoordinator
        } else {
            return nil
        }
    }
    
    public var presentedCoordinator: CocoaPresentationCoordinator? {
        if let presentedViewController = viewController.presentedViewController {
            return presentedViewController.runtimePresentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(after: viewController)?.runtimePresentationCoordinator
        } else {
            return nil
        }
    }
    
    var onDidAttemptToDismiss: [AnyModalPresentation.DidAttemptToDismissCallback] = []
    var transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    private weak var viewController: UIViewController!
        
    public init(
        presentation: AnyModalPresentation? = nil,
        viewController: UIViewController? = nil
    ) {
        self.presentation = presentation
        self.viewController = viewController
    }
    
    func setViewController(_ viewController: UIViewController) {
        guard self.viewController == nil else {
            return assertionFailure()
        }
        
        self.viewController = viewController
    }
    
    func setIsInActivePresentation(_ isActive: Bool) {
        viewController.isModalInPresentation = isActive
    }
}

extension CocoaPresentationCoordinator {
    public override var description: String {
        if let name = presentedViewName {
            return "Bridged Presentation Coordinator (" + name.description + ")"
        } else {
            return "Bridged Presentation Coordinator"
        }
    }
}

// MARK: - Protocol Implementations -

extension CocoaPresentationCoordinator: DynamicViewPresenter {
    public var presenting: DynamicViewPresenter? {
        presentingCoordinator
    }
    
    public var presented: DynamicViewPresenter? {
        presentedCoordinator
    }
    
    public var presentedViewName: ViewName? {
        presentedCoordinator?.presentation?.contentName ?? (viewController as? opaque_CocoaController)?.rootViewName
    }
    
    public func present(_ modal: AnyModalPresentation) {
        if let viewController = viewController.presentedViewController as? CocoaPresentationHostingController, viewController.modalViewPresentationStyle == modal.presentationStyle {
            viewController.rootView.content.presentation = modal
            return
        }
        
        viewController.present(
            CocoaPresentationHostingController(
                presentation: modal,
                coordinator: .init(presentation: modal)
            ),
            animated: modal.animated,
            completion: modal.completion
        )
    }
    
    public func dismiss(completion: @escaping () -> Void) {
        guard isPresenting else {
            return
        }
        
        guard let viewController = viewController else {
            return
        }
        
        if let presentation = presentation, !presentation.shouldDismiss() {
            return
        }
        
        viewController.dismiss(animated: true) {
            self.presentation?.onDismiss()
            
            completion()
        }
    }
}

extension CocoaPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if let presentation = presentation {
            return .init(presentation.presentationStyle)
        } else {
            return .automatic
        }
    }
    
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        presentation?.shouldDismiss() ?? true
    }
    
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        for callback in onDidAttemptToDismiss {
            callback.action()
        }
    }
    
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentation?.onDismiss()
    }
}

#endif
