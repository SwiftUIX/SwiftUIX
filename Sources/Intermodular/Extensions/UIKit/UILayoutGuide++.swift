//
// Copyright (c) Vatsal Manot.
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UILayoutGuide {
    func constrainDimensions(to size: CGSize) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    func constrainRect(of other: UIView) {
        other.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: other.centerXAnchor),
            centerYAnchor.constraint(equalTo: other.centerYAnchor),
            widthAnchor.constraint(equalTo: other.widthAnchor),
            heightAnchor.constraint(equalTo: other.heightAnchor)
        ])
    }
    
    func constrainSubview(_ subview: UIView) {
        subview.constrainEdges(to: self)
    }
}

#endif
