//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

@available(iOS 15.0, macOS 10.15, watchOS 9.0, *)
@available(tvOS, unavailable)
extension NSButton.ControlSize {
    public init(_ size: SwiftUI.ControlSize) {
        switch size {
            case .mini:
                self = .mini
            case .small:
                self = .small
            case .regular:
                self = .regular
            case .large:
                if #available(macOS 11.0, *) {
                    self = .large
                } else {
                    self = .regular
                }
            default:
                assertionFailure()
                
                self = .regular
        }
    }
}

#endif
