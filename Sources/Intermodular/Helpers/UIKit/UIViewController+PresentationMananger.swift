//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

private var runtimePresentationCoordinatorKey: Void = ()

extension UIViewController: DynamicViewPresenter {
    var runtimePresentationCoordinator: CocoaPresentationCoordinator {
        if let coordinator = (self as? opaque_CocoaController)?.presentationCoordinator {
            return coordinator
        }
        
        if let coordinator = objc_getAssociatedObject(self, &runtimePresentationCoordinatorKey) {
            return coordinator as! CocoaPresentationCoordinator
        } else {
            let coordinator = CocoaPresentationCoordinator(viewController: self)
            
            objc_setAssociatedObject(self, &runtimePresentationCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            
            return coordinator
        }
    }
    
    public var presenting: DynamicViewPresenter? {
        runtimePresentationCoordinator.presenting
    }
    
    public var presented: DynamicViewPresenter? {
        runtimePresentationCoordinator.presented
    }
    
    public var presentedViewName: ViewName? {
        runtimePresentationCoordinator.presentedViewName
    }
    
    public func dismiss(completion: @escaping () -> Void) {
        runtimePresentationCoordinator.dismiss(completion: completion)
    }
    
    public func present(_ presentation: AnyModalPresentation) {
        runtimePresentationCoordinator.present(presentation)
    }
}

#endif
