//
// Copyright (c) Vatsal Manot
//

#if os(macOS)
import AppKit
#endif
import QuartzCore
import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if compiler(>=6.3)
#if canImport(AppKit)
import AppKit

/// Fix for Xcode 26.4 because Apple is fucking retarded.
extension NSTextAttachment {
    static var character: Int {
        #if targetEnvironment(macCatalyst)
        return 0xFFFC
        #else
        return NSAttachmentCharacter
        #endif
    }
}
#endif
#endif
