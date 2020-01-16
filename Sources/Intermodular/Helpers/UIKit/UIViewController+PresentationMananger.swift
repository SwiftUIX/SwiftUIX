//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

private var presentationCoordinatorKey: Void = ()

extension UIViewController: DynamicViewPresenter {
    private var objc_associated_presentationCoordinator: CocoaPresentationCoordinator {
        if let coordinator = (self as? opaque_CocoaController)?.presentationCoordinator {
            return coordinator
        }
        
        if let coordinator = objc_getAssociatedObject(self, &presentationCoordinatorKey) {
            return coordinator as! CocoaPresentationCoordinator
        } else {
            let coordinator = CocoaPresentationCoordinator()
            
            coordinator.viewController = self
            
            objc_setAssociatedObject(self, &presentationCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            
            return coordinator
        }
    }
    
    public var isPresented: Bool {
        objc_associated_presentationCoordinator.isPresented
    }
    
    public func dismiss() {
        objc_associated_presentationCoordinator.dismiss()
    }
    
    public func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)?,
        style: ModalViewPresentationStyle
    ) {
        objc_associated_presentationCoordinator.present(
            view,
            onDismiss: onDismiss,
            style: style
        )
    }
    
    public func dismiss(viewNamed name: ViewName) {
        objc_associated_presentationCoordinator.dismiss(viewNamed: name)
    }
}

#endif
