//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyEquivalent {
    public static let DEL = Self("\u{7F}" as Character)
    public static let backspace = Self("\u{08}" as Character)
    
    public var _isDeleteOrBackspace: Bool {
        switch self {
            case .DEL:
                return true
            case .delete:
                return true
            case .backspace:
                return true
            default:
                return false
        }
    }
}

#if !os(visionOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyEquivalent {
    public static func ~= (lhs: KeyEquivalent, rhs: KeyEquivalent) -> Bool {
        lhs.character == rhs.character
    }
    
    @_disfavoredOverload
    public static func == (lhs: KeyEquivalent, rhs: KeyEquivalent) -> Bool {
        lhs.character == rhs.character
    }
}
#endif

#if compiler(>=5.8)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyEquivalent: @unchecked Sendable {
    
}
#endif
