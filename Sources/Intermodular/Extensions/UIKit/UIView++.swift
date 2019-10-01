//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import UIKit

extension UIView {
    public func constrain(to other: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: other.centerXAnchor),
            centerYAnchor.constraint(equalTo: other.centerYAnchor),
            widthAnchor.constraint(equalTo: other.widthAnchor),
            heightAnchor.constraint(equalTo: other.heightAnchor)
        ])
    }
}

#endif
