//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

@objc public class CocoaPresentationCoordinator: NSObject, ObservableObject {
    public var environmentBuilder = EnvironmentBuilder()
    
    private let presentation: AnyModalPresentation?
    
    public var presentingCoordinator: CocoaPresentationCoordinator? {
        if let presentingViewController = viewController.presentingViewController {
            return presentingViewController.presentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(before: viewController)?.presentationCoordinator
        } else {
            return nil
        }
    }
    
    public var presentedCoordinator: CocoaPresentationCoordinator? {
        if let presentedViewController = viewController.presentedViewController {
            return presentedViewController.presentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(after: viewController)?.presentationCoordinator
        } else {
            return nil
        }
    }
    
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
    
    func setIsInPresentation(_ isActive: Bool) {
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
    public var presenter: DynamicViewPresenter? {
        presentingCoordinator
    }
    
    public var presented: DynamicViewPresentable? {
        presentedCoordinator
    }
    
    public var presentedViewName: ViewName? {
        presentedCoordinator?.presentation?.content.opaque_getViewName()
    }
    
    public func present(_ modal: AnyModalPresentation) {
        if let viewController = viewController.presentedViewController as? CocoaPresentationHostingController, viewController.modalViewPresentationStyle == modal.content.presentationStyle {
            viewController.rootView.content.presentation = modal
            return
        }
        
        viewController.present(
            CocoaPresentationHostingController(
                presentation: modal,
                coordinator: .init(presentation: modal)
            ),
            animated: modal.content.isModalPresentationAnimated
        ) {
            modal.content.onPresent()
            
            self.objectWillChange.send()
        }
    }
    
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        guard isPresenting else {
            return
        }
        
        guard let viewController = viewController else {
            return
        }
        
        if let presentation = presentation, !presentation.content.isModalDismissable {
            return
        }
        
        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: animated) {
                self.presentation?.content.onDismiss()
                
                completion?()
            }
        } else if let navigationController = viewController.navigationController {
            navigationController.popToViewController(viewController, animated: animated) {
                self.presentation?.content.onDismiss()
                
                completion?()
            }
        }
    }
}

extension CocoaPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if let presentation = presentation {
            return .init(presentation.content.presentationStyle)
        } else {
            return .automatic
        }
    }
    
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        presentation?.content.isModalDismissable ?? true
    }
    
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        objectWillChange.send()
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentation?.content.onDismiss()
        
        presentationController.presentingViewController.presentationCoordinator.objectWillChange.send()
    }
}

// MARK: - Helpers -

extension CocoaPresentationCoordinator {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: CocoaPresentationCoordinator? = nil
    }
}

extension EnvironmentValues {
    public var cocoaPresentationCoordinator: CocoaPresentationCoordinator? {
        get {
            self[CocoaPresentationCoordinator.EnvironmentKey]
        } set {
            self[CocoaPresentationCoordinator.EnvironmentKey] = newValue
        }
    }
}

#endif
