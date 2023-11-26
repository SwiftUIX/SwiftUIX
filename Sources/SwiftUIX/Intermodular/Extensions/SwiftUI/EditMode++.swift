//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension EditMode {
    public mutating func toggle() {
        switch self {
            case .inactive:
                self = .active
            case .transient:
                self = .inactive
            case .active:
                self = .inactive
            @unknown default:
                self = .inactive
        }
    }
}
