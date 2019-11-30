//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

open class Keyboard {
    open class func dismiss() {
        UIApplication.shared.firstKeyWindow?.endEditing(true)
    }
}

#endif
