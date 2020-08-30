//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIResponder {
    var globalFrame: CGRect? {
        guard let view = self as? UIView else {
            return nil
        }
        
        return view.superview?.convert(view.frame, to: nil)
    }
}

extension UIResponder {
    private static weak var _firstResponder: UIResponder?
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    static var firstResponder: UIResponder? {
        _firstResponder = nil
        
        UIApplication.shared.sendAction(#selector(UIResponder.acquireFirstResponder(_:)), to: nil, from: nil, for: nil)
        
        return _firstResponder
    }
    
    @objc private func acquireFirstResponder(_ sender: Any) {
        UIResponder._firstResponder = self
    }
}

extension UIResponder {
    open func nearestResponder<Responder: UIResponder>(ofKind kind: Responder.Type) -> Responder? {
        guard !isKind(of: kind) else {
            return (self as! Responder)
        }
        
        return next?.nearestResponder(ofKind: kind)
    }
    
    private func furthestResponder<Responder: UIResponder>(ofKind kind: Responder.Type, default _default: Responder?) -> Responder? {
        return next?.furthestResponder(ofKind: kind, default: self as? Responder) ?? _default
    }
    
    open func furthestResponder<Responder: UIResponder>(ofKind kind: Responder.Type) -> Responder? {
        return furthestResponder(ofKind: kind, default: nil)
    }
    
    open func forEach<Responder: UIResponder>(ofKind kind: Responder.Type, recursive iterator: (Responder) throws -> ()) rethrows {
        if isKind(of: kind) {
            try iterator(self as! Responder)
        }
        
        try next?.forEach(ofKind: kind, recursive: iterator)
    }
}

extension UIResponder {
    @objc open var nearestViewController: UIViewController? {
        nearestResponder(ofKind: UIViewController.self)
    }
    
    @objc open var furthestViewController: UIViewController? {
        furthestResponder(ofKind: UIViewController.self)
    }
    
    @objc open var nearestNavigationController: UINavigationController? {
        nearestResponder(ofKind: UINavigationController.self)
    }
    
    @objc open var furthestNavigationController: UINavigationController? {
        furthestResponder(ofKind: UINavigationController.self)
    }
}

#endif
