//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

@objc public class CocoaPresentationCoordinator: NSObject, ObservableObject {
    public var environmentBuilder = EnvironmentBuilder()
    
    private let presentation: AnyModalPresentation?
    private var stagedPresentation: AnyModalPresentation?
    
    public var subviews: [ViewDescription] = [] {
        didSet {
            print(subviews)
        }
    }
    
    public var presentingCoordinator: CocoaPresentationCoordinator? {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let presentingViewController = viewController.presentingViewController {
            return presentingViewController.presentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(before: viewController)?.presentationCoordinator
        } else {
            return nil
        }
        #elseif os(macOS)
        if let presentingViewController = viewController.presentingViewController {
            return presentingViewController.presentationCoordinator
        } else {
            return nil
        }
        #endif
    }
    
    public var presentedCoordinator: CocoaPresentationCoordinator? {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let presentedViewController = viewController.presentedViewController {
            return presentedViewController.presentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(after: viewController)?.presentationCoordinator
        } else {
            return nil
        }
        #elseif os(macOS)
        if let presentedViewControllers = viewController.presentedViewControllers, presentedViewControllers.count == 1 {
            return presentedViewControllers.first?.presentationCoordinator
        } else {
            return nil
        }
        #endif
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    var transitioningDelegate: UIViewControllerTransitioningDelegate?
    #endif
    
    private weak var viewController: AppKitOrUIKitViewController!
    
    public init(
        presentation: AnyModalPresentation? = nil,
        viewController: AppKitOrUIKitViewController? = nil
    ) {
        self.presentation = presentation
        self.viewController = viewController
    }
    
    func setViewController(_ viewController: AppKitOrUIKitViewController) {
        guard self.viewController == nil else {
            return assertionFailure()
        }
        
        self.viewController = viewController
    }
    
    func setIsInPresentation(_ isActive: Bool) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        viewController.isModalInPresentation = isActive
        #elseif os(macOS)
        fatalError("unimplemented")
        #endif
    }
}

extension CocoaPresentationCoordinator {
    public override var description: String {
        if let name = presentationName {
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
    
    public var presentationName: ViewName? {
        presentation?.content._opaque_getViewName()
    }
    
    public func present(_ modal: AnyModalPresentation) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let viewController = viewController.presentedViewController as? CocoaPresentationHostingController, viewController.modalViewPresentationStyle == modal.content.presentationStyle {
            viewController.rootView.content.presentation = modal
            return
        }
        
        viewController.present(
            CocoaPresentationHostingController(
                presentingViewController: viewController,
                presentation: modal,
                coordinator: .init(presentation: modal)
            ),
            animated: modal.content.isModalPresentationAnimated
        ) {
            modal.content.onPresent()
            
            self.objectWillChange.send()
        }
        #elseif os(macOS)
        fatalError("unimplemented")
        #endif
    }
    
    @discardableResult
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard isPresenting else {
            return .init({ $0(.success(false)) })
        }
        
        guard let viewController = viewController else {
            return .init({ $0(.success(false)) })
        }
        
        let presentation = presentedCoordinator?.presentation
        
        if let presentation = presentation, !presentation.content.isModalDismissable {
            return .init({ $0(.success(false)) })
        }
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return .init { attemptToFulfill in
            if viewController.presentedViewController != nil {
                self.objectWillChange.send()
                
                viewController.dismiss(animated: animation != nil) {
                    presentation?.content.onDismiss()
                    presentation?.resetBinding()
                    
                    attemptToFulfill(.success(true))
                }
            } else if let navigationController = viewController.navigationController {
                self.objectWillChange.send()
                
                navigationController.popToViewController(viewController, animated: animation != nil) {
                    presentation?.content.onDismiss()
                    presentation?.resetBinding()
                    
                    attemptToFulfill(.success(true))
                }
            }
        }
        #elseif os(macOS)
        fatalError("unimplemented")
        #endif
    }
    
    @discardableResult
    public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        viewController.dismissSelf(withAnimation: animation)
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension CocoaPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        #if !os(tvOS)
        if controller is UIPopoverPresentationController {
            return .none
        }
        #endif
        
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
    
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        
    }
}

#endif

#if os(iOS) && !os(tvOS)

extension CocoaPresentationCoordinator: UIPopoverPresentationControllerDelegate {
    
}

#endif

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
