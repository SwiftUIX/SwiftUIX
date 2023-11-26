//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIViewController {
    public var root: UIViewController? {
        var parent = self.parent
        
        while let _parent = parent?.parent {
            parent = _parent
        }
        
        return parent
    }
}

extension UIViewController {
    public var topmostNavigationController: UINavigationController? {
        topmostViewController?.nearestNavigationController ?? nearestNavigationController
    }
    
    override open var nearestNavigationController: UINavigationController? {
        navigationController
            ?? _nearestChild(ofKind: UINavigationController.self)
            ?? _nearestResponder(ofKind: UINavigationController.self)
    }

    var _nearestSplitViewController: UISplitViewController? {
        splitViewController ?? nearestNavigationController?.splitViewController ?? _nearestResponder(ofKind: UISplitViewController.self)
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
    
    public func _nearestChild<T: UIViewController>(
        ofKind kind: T.Type,
        maximumDepth: Int? = nil
    ) -> T? {
        _nearestChild(ofKind: kind, currentDepth: nil, maximumDepth: maximumDepth)
    }
    
    public func _SwiftUIX_findSubview<T: UIView>(ofKind kind: T.Type) -> T? {
        view._SwiftUIX_findSubview(ofKind: kind) ?? _decomposeChildViewControllers().lazy.compactMap({ $0.view._SwiftUIX_findSubview(ofKind: kind) }).first
    }
    
    private func _nearestChild<T: UIViewController>(
        ofKind kind: T.Type,
        currentDepth: Int?,
        maximumDepth: Int?
    ) -> T? {
        var currentDepth = currentDepth
        
        if maximumDepth != nil {
            currentDepth = currentDepth.map({ $0 + 1 }) ?? 0
        }
        
        if let currentDepth = currentDepth {
            if currentDepth == maximumDepth {
                return nil
            }
        }
        
        if let result = presentedViewController?._nearestChild(
            ofKind: kind,
            currentDepth: currentDepth,
            maximumDepth: maximumDepth
        ) {
            return result
        }
        
        for child in children {
            if let child = (child as? UITabBarController)?.selectedViewController {
                if let child = child._nearestChild(
                    ofKind: kind,
                    currentDepth: currentDepth,
                    maximumDepth: maximumDepth
                ) {
                    return child
                }
            }
            
            if let child = (child as? UINavigationController)?.visibleViewController {
                if let child = child._nearestChild(
                    ofKind: kind,
                    currentDepth: currentDepth,
                    maximumDepth: maximumDepth
                ) {
                    return child
                }
            }
            
            if child.isKind(of: kind) {
                return child as? T
            } else if let result = child._nearestChild(
                ofKind: kind,
                currentDepth: currentDepth,
                maximumDepth: maximumDepth
            ) {
                return result
            }
        }
        
        return nil
    }
}

extension UIViewController {
    public func _SwiftUIX_addChild(_ child: UIViewController) {
        child.willMove(toParent: self)
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    public func _SwiftUIX_asChildRemoveFromParent() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

#endif

