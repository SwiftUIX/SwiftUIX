//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIViewController {
    var topMostPresentedViewController: UIViewController? {
        var topController = self
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        return topController
    }
    
    var topMostViewController: UIViewController {
        topMostPresentedViewController ?? self
    }
        
    override open var nearestNavigationController: UINavigationController? {
        nil
            ?? nearestChild(ofKind: UINavigationController.self)
            ?? nearestResponder(ofKind: UINavigationController.self)
            ?? navigationController
    }
    
    func nearestChild<T: UIViewController>(ofKind kind: T.Type) -> T? {
        guard !children.isEmpty else {
            return nil
        }
        
        for child in children {
            if child.isKind(of: kind) {
                return child as? T
            } else if let result = child.nearestChild(ofKind: kind) {
                return result
            }
        }
        
        if let result = presentedViewController?.nearestChild(ofKind: kind) {
            return result
        }
        
        return nil
    }
}

#endif

