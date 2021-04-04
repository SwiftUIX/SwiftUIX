//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import SwiftUI
import UIKit

extension UIEdgeInsets {
    public var horizontal: CGFloat {
        return left + right
    }
    
    public var vertical: CGFloat {
        return top + bottom
    }
    
    public static prefix func - (_ inset: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: -inset.top,
            left: -inset.left,
            bottom: -inset.bottom,
            right: -inset.right
        )
    }
    
    public init(all offset: CGFloat) {
        self.init(top: offset, left: offset, bottom: offset, right: offset)
    }
    
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical / 2, left: horizontal / 2, bottom: vertical / 2, right: horizontal / 2)
    }
}

extension UIEdgeInsets {
    public init(_ insets: EdgeInsets) {
        self.init(
            top: insets.top,
            left: insets.leading,
            bottom: insets.bottom,
            right: insets.trailing
        )
    }
}

#endif
