//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import UIKit

extension UIViewController {
    func findChild<T: UIViewController>(ofKind kind: T.Type) -> T? {
        guard !children.isEmpty else {
            return nil
        }
        
        for child in children {
            if child.isKind(of: kind) {
                return child as? T
            } else if let result = child.findChild(ofKind: kind) {
                return result
            }
        }
        
        return nil
    }
}

#endif

