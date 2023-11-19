//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

extension UINavigationController {
    func viewController(before viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllers.indices.contains(index - 1) {
            return viewControllers[index - 1]
        } else {
            return nil
        }
    }
    
    func viewController(after viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllers.indices.contains(index + 1) {
            return viewControllers[index + 1]
        } else {
            return nil
        }
    }
    
    func popToViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        popToViewController(viewController, animated: animated)
        
        guard let completion = completion else {
            return
        }
        
        guard animated, let coordinator = transitionCoordinator else {
            return DispatchQueue.main.async(execute: { completion() })
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
}

#endif
