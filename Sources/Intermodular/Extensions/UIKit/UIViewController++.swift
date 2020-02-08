//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

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

