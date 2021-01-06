//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum FocusRingType: UInt {
    case `default` = 0
    case none      = 1
    case exterior  = 2
}

// MARK: - Auxiliary Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIView {
    var _focusRingType: FocusRingType {
        get {
            (self.value(forKey: "focusRingType") as? UInt).flatMap(FocusRingType.init) ?? .default
        } set {
            setValue(newValue.rawValue, forKey: "focusRingType")
        }
    }
}

#endif
