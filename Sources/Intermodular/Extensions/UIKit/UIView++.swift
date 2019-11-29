//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

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
    
    func constrainSubview(_ subview: UIView) {
        if subview.superview == nil {
            addSubview(subview)
        }
        
        subview.constrain(to: self)
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

extension UIView {
    func findSubview<T: UIView>(ofKind kind: T.Type) -> T? {
        guard !subviews.isEmpty else {
            return nil
        }
        
        for subview in subviews {
            if subview.isKind(of: kind) {
                return subview as? T
            } else if let result = subview.findSubview(ofKind: kind) {
                return result
            }
        }
        
        return nil
    }
}

#endif
