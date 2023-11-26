//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIView {
    var _parentViewController: UIViewController? {
        guard let result = _nearestResponder(ofKind: UIViewController.self), result.view == self else {
            return nil
        }
        
        return result
    }
}

extension UIView {
    public func _SwiftUIX_findFirstResponder() -> UIView? {
        guard !isFirstResponder else {
            return self
        }
        
        for subview in subviews {
            if let firstResponder = subview._SwiftUIX_findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}

extension UIViewController {
    public func _SwiftUIX_findFirstResponder() -> AppKitOrUIKitResponder? {
        guard !isFirstResponder else {
            return self
        }
        
        for subview in view.subviews {
            if let firstResponder = subview._SwiftUIX_findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}

extension UIView {
    func constrain(to other: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: other.centerXAnchor),
            centerYAnchor.constraint(equalTo: other.centerYAnchor),
            widthAnchor.constraint(equalTo: other.widthAnchor),
            heightAnchor.constraint(equalTo: other.heightAnchor)
        ])
    }
    
    func constrainEdges(to other: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: other.leadingAnchor),
            trailingAnchor.constraint(equalTo: other.trailingAnchor),
            topAnchor.constraint(equalTo: other.topAnchor),
            bottomAnchor.constraint(equalTo: other.bottomAnchor)
        ])
    }
    
    func constrainSubview(_ subview: UIView) {
        if subview.superview == nil {
            addSubview(subview)
        }
        
        subview.constrain(to: self)
    }
    
    func constrainSubviewEdges(_ subview: UIView) {
        if subview.superview == nil {
            addSubview(subview)
        }
        
        subview.constrainEdges(to: self)
    }
    
    func constrainEdges(to guide: UILayoutGuide) {
        if superview == nil {
            guide.owningView?.addSubview(self)
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            topAnchor.constraint(equalTo: guide.topAnchor),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}

extension UIView {
    public func addSwipeGestureRecognizer(
        for direction: UISwipeGestureRecognizer.Direction,
        target: Any?,
        action: Selector
    ) {
        addGestureRecognizer(UISwipeGestureRecognizer(target: target, action: action).then {
            $0.direction = direction
        })
    }
}

extension UIView {
    func takeSnapshot() -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        let image = renderer.image { (context) in
            UIGraphicsPushContext(context.cgContext)
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
            UIGraphicsPopContext()
        }
        
        return image
    }
}

#endif
