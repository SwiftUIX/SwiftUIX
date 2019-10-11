//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

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

#endif
