//
// Copyright (c) Vatsal Manot.
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UINavigationBar {
    @inlinable
    var isDefaultTransparent: Bool {
        get {
            return true
                && backgroundImage(for: .default)?.size == .zero
                && shadowImage?.size == .zero
        } set {
            setBackgroundImage(newValue ? UIImage() : nil, for: .default)
            shadowImage = newValue ? UIImage() : nil
        }
    }
}

#endif
