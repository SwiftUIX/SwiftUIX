//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyEquivalent {
    public static let DEL = Self("\u{7F}")
    public static let backspace = Self("\u{08}")
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyEquivalent {
    public static func ~= (lhs: KeyEquivalent, rhs: KeyEquivalent) -> Bool {
        lhs.character == rhs.character
    }
    
    public static func == (lhs: KeyEquivalent, rhs: KeyEquivalent) -> Bool {
        lhs.character == rhs.character
    }
}

#if compiler(>=5.8)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyEquivalent: @unchecked Sendable {
    
}
#endif
