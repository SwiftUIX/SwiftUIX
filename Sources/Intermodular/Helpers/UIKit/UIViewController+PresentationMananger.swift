//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

private var presentationCoordinatorKey: Void = ()

extension UIViewController: DynamicViewPresenter {
    public var objc_associated_presentationCoordinator: CocoaPresentationCoordinator {
        if let coordinator = (self as? opaque_CocoaController)?.presentationCoordinator {
            return coordinator
        }
        
        if let coordinator = objc_getAssociatedObject(self, &presentationCoordinatorKey) {
            return coordinator as! CocoaPresentationCoordinator
        } else {
            let coordinator = CocoaPresentationCoordinator(presentingCoordinator: presentingViewController?.objc_associated_presentationCoordinator)
            
            coordinator.viewController = self
            
            objc_setAssociatedObject(self, &presentationCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            
            return coordinator
        }
    }
    
    public var isPresented: Bool {
        objc_associated_presentationCoordinator.isPresented
    }
    
    public var presentedViewName: ViewName? {
        objc_associated_presentationCoordinator.presentedViewName
    }
    
    public func dismiss(completion: (() -> Void)?) {
        objc_associated_presentationCoordinator.dismiss(completion: completion)
    }
    
    public func dismiss() {
        dismiss(completion: nil)
    }
    
    public func present<V: View>(
        _ view: V,
        named viewName: ViewName? = nil,
        onDismiss: (() -> Void)?,
        style: ModalViewPresentationStyle,
        completion: (() -> Void)?
    ) {
        objc_associated_presentationCoordinator.present(
            view,
            named: viewName,
            onDismiss: onDismiss,
            style: style,
            completion: completion
        )
    }
    
    public func dismissView(named name: ViewName) {
        objc_associated_presentationCoordinator.dismissView(named: name)
    }
}

#endif
