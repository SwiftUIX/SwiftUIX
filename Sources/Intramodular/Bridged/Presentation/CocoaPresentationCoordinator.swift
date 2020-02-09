//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class CocoaPresentationCoordinator: NSObject {
    private let presentation: AnyModalPresentation?
    
    public private(set) weak var presentingCoordinator: CocoaPresentationCoordinator?
    public private(set) var presentedCoordinator: CocoaPresentationCoordinator?
    
    var topMostCoordinator: CocoaPresentationCoordinator {
        var coordinator = self
        
        while let nextCoordinator = coordinator.presentedCoordinator {
            coordinator = nextCoordinator
        }
        
        return coordinator
    }
    
    var topMostPresentedCoordinator: CocoaPresentationCoordinator? {
        presentedCoordinator?.topMostCoordinator
    }
    
    var onDidAttemptToDismiss: [AnyModalPresentation.DidAttemptToDismissCallback] = []
    var transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    weak var viewController: UIViewController?
    
    init(
        presentation: AnyModalPresentation,
        presentingCoordinator: CocoaPresentationCoordinator
    ) {
        self.presentation = presentation
        self.presentingCoordinator = presentingCoordinator
    }
    
    init(parent: CocoaPresentationCoordinator?) {
        self.presentation = nil

        super.init()
        
        presentingCoordinator = parent ?? self
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
    
    public var isPresented: Bool {
        return presentedCoordinator != nil
    }
    
    public var presentedViewName: ViewName? {
        presentedCoordinator?.presentation?.contentName ?? (viewController as? opaque_CocoaController)?.rootViewName
    }
    
    public func present(_ modal: AnyModalPresentation) {
        if let viewController = viewController?.presentedViewController as? CocoaPresentationHostingController, viewController.modalViewPresentationStyle == modal.presentationStyle {
            viewController.rootView.content.presentation = modal
            return
        }
        
        viewController?.present(
            CocoaPresentationHostingController(
                presentation: modal,
                coordinator: .init(
                    presentation: modal,
                    presentingCoordinator: self
                )
            ).then {
                presentedCoordinator = $0.presentationCoordinator
            },
            animated: modal.animated,
            completion: modal.completion
        )
    }
    
    public func dismiss(completion: @escaping () -> Void) {
        guard
            let viewController = viewController,
            let presentedCoordinator = presentedCoordinator,
            let presentation = presentedCoordinator.presentation,
            viewController.presentedViewController != nil,
            presentation.shouldDismiss() else {
                return
        }
        
        viewController.dismiss(animated: true) {
            presentation.onDismiss()
            self.presentedCoordinator = nil
            completion()
        }
    }
    
    public func dismiss() {
        dismiss(completion: { })
    }
    
    public func dismissView(
        named name: ViewName,
        completion: @escaping () -> Void
    ) {
        var coordinator: CocoaPresentationCoordinator? = presentingCoordinator ?? self
        
        while let presentedCoordinator = coordinator {
            if presentedCoordinator.presentedViewName == name {
                presentedCoordinator.dismiss(completion: completion)
                break
            }
            
            coordinator = coordinator?.presentedCoordinator
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
        
        presentingCoordinator?.presentedCoordinator = nil
    }
}

#endif
