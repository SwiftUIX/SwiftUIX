//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

extension UINavigationController {
    public func viewController(before viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllers.indices.contains(index - 1) {
            return viewControllers[index - 1]
        } else {
            return nil
        }
    }
    
    public func viewController(after viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllers.indices.contains(index + 1) {
            return viewControllers[index + 1]
        } else {
            return nil
        }
    }
}

#endif
