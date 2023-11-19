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

// MARK: - Auxiliary

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitView {
    var _focusRingType: FocusRingType {
        get {
            (self.value(forKey: "focusRingType") as? UInt).flatMap(FocusRingType.init) ?? .default
        } set {
            setValue(newValue.rawValue, forKey: "focusRingType")
        }
    }
}
#endif
