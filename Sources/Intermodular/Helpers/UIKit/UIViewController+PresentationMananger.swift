//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

private var runtimePresentationCoordinatorKey: Void = ()

extension UIViewController: DynamicViewPresenter {
    @objc open var presentationCoordinator: CocoaPresentationCoordinator {
        if let coordinator = objc_getAssociatedObject(self, &runtimePresentationCoordinatorKey) {
            return coordinator as! CocoaPresentationCoordinator
        } else {
            let coordinator = CocoaPresentationCoordinator(viewController: self)
            
            objc_setAssociatedObject(self, &runtimePresentationCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            
            return coordinator
        }
    }
    
    public var presenting: DynamicViewPresenter? {
        presentationCoordinator.presenting
    }
    
    public var presented: DynamicViewPresenter? {
        presentationCoordinator.presented
    }
    
    public var presentedViewName: ViewName? {
        presentationCoordinator.presentedViewName
    }
    
    public func dismiss(completion: @escaping () -> Void) {
        presentationCoordinator.dismiss(completion: completion)
    }
    
    public func present(_ presentation: AnyModalPresentation) {
        presentationCoordinator.present(presentation)
    }
}

#endif
