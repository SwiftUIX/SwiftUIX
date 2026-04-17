//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Foundation
import Swift
import SwiftUI

extension NSAttributedString {
    public var _isSingleTextAttachment: Bool {
        guard length == 1, self.string.first! == Character(UnicodeScalar(NSTextAttachment.character)!) else {
            return false
        }
        
        return true
    }
}

#endif

/// NSTextAttachment.character -> NSAttachmentCharacter
#if compiler(>=6.3)
#if canImport(AppKit)
import AppKit

/// Fix for XCode 26.4
extension NSTextAttachment {
    static var character: Int {
        NSAttachmentCharacter
    }
}
#endif
#endif
