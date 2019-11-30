//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import UIKit

extension UIApplication {
    public var firstKeyWindow: UIWindow? {
        windows.first(where: { $0.isKeyWindow })
    }
}

#endif
