//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A type to mirror `SwiftUI.RedactionReasons`, added for compatibility.
/// The reasons to apply a redaction to data displayed on screen.
@_documentation(visibility: internal)
public struct RedactionReasons: OptionSet {
    /// The raw value.
    public let rawValue: Int
    
    /// Creates a new set from a raw value.
    ///
    /// - Parameter rawValue: The raw value with which to create the
    ///   reasons for redaction.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Displayed data should appear as generic placeholders.
    ///
    /// Text and images will be automatically masked to appear as
    /// generic placeholders, though maintaining their original size and shape.
    /// Use this to create a placeholder UI without directly exposing
    /// placeholder data to users.
    public static let placeholder = Self(rawValue: 1 << 0)
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension SwiftUI.RedactionReasons {
    public init(_ redactionReasons: RedactionReasons) {
        var swiftUIRedactionReasons: SwiftUI.RedactionReasons = []
        
        if redactionReasons.contains(.placeholder) {
            swiftUIRedactionReasons.insert(.placeholder)
        }
        
        self = swiftUIRedactionReasons
    }
}
