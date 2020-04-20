//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIViewController {
    open var topmostNavigationController: UINavigationController? {
        topmostViewController?.nearestNavigationController ?? nearestNavigationController
    }
    
    override open var nearestNavigationController: UINavigationController? {
        nil
            ?? nearestChild(ofKind: UINavigationController.self)
            ?? navigationController
            ?? nearestResponder(ofKind: UINavigationController.self)
    }
}

extension UIViewController {
    public var topmostPresentedViewController: UIViewController? {
        presentedViewController?.topmostPresentedViewController ?? self
    }
    
    public var topmostViewController: UIViewController? {
        if let controller = (self as? UINavigationController)?.visibleViewController {
            return controller.topmostViewController
        } else if let controller = (self as? UITabBarController)?.selectedViewController {
            return controller.topmostViewController
        } else if let controller = presentedViewController {
            return controller.topmostViewController
        } else {
            return self
        }
    }
    
    func nearestChild<T: UIViewController>(ofKind kind: T.Type) -> T? {
        if let result = presentedViewController?.nearestChild(ofKind: kind) {
            return result
        }
        
        for child in children {
            if let child = (child as? UITabBarController)?.selectedViewController {
                if let child = child.nearestChild(ofKind: kind) {
                    return child
                }
            }
            
            if let child = (child as? UINavigationController)?.visibleViewController {
                if let child = child.nearestChild(ofKind: kind) {
                    return child
                }
            }
            
            if child.isKind(of: kind) {
                return child as? T
            } else if let result = child.nearestChild(ofKind: kind) {
                return result
            }
        }
        
        return nil
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        child.willMove(toParent: self)
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

#endif

