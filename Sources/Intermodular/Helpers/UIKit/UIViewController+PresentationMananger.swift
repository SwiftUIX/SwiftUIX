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
            let coordinator = CocoaPresentationCoordinator(parent: presentingViewController?.objc_associated_presentationCoordinator)
            
            coordinator.viewController = self
            
            objc_setAssociatedObject(self, &presentationCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            
            return coordinator
        }
    }
    
    public var presenting: DynamicViewPresenter? {
        objc_associated_presentationCoordinator.presenting
    }
    
    public var presented: DynamicViewPresenter? {
        objc_associated_presentationCoordinator.presented
    }

    public var presentedViewName: ViewName? {
        objc_associated_presentationCoordinator.presentedViewName
    }
    
    public func dismiss(completion: @escaping () -> Void) {
        objc_associated_presentationCoordinator.dismiss(completion: completion)
    }
        
    public func dismiss() {
        dismiss(completion: { })
    }

    public func present(_ presentation: AnyModalPresentation) {
        objc_associated_presentationCoordinator.present(presentation)
    }
    
    public func dismissView(
        named name: ViewName,
        completion: @escaping () -> Void
    ) {
        objc_associated_presentationCoordinator.dismissView(named: name, completion: completion)
    }
}

#endif
