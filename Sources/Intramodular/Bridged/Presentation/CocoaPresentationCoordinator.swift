//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

@objc public class CocoaPresentationCoordinator: NSObject, ObservableObject {
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
    public var presenting: DynamicViewPresenter? {
        presentingCoordinator
    }
    
    public var presented: DynamicViewPresenter? {
        presentedCoordinator
    }
    
    public var presentedViewName: ViewName? {
        presentedCoordinator?.presentation?.contentName
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
            animated: modal.animated
        ) {
            modal.completion()
            
            self.objectWillChange.send()
        }
    }
    
    private func dismiss(animated: Bool, completion: @escaping () -> Void) {
        guard isPresenting else {
            return
        }
        
        guard let viewController = viewController else {
            return
        }
        
        if let presentation = presentation, !presentation.shouldDismiss() {
            return
        }
        
        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: true) {
                self.presentation?.onDismiss()
                
                completion()
            }
        } else if let navigationController = viewController.navigationController {
            navigationController.popToViewController(viewController, animated: animated) {
                self.presentation?.onDismiss()
                
                completion()
            }
        }
    }
    
    public func dismiss(completion: @escaping () -> Void) {
        dismiss(animated: true, completion: completion)
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
    
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        objectWillChange.send()
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentation?.onDismiss()
        
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
