//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
extension Label where Title == Text, Icon == Image {
    /// Creates a label with a system icon image and a title generated from a
    /// localized string.
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
    public init(_ titleKey: LocalizedStringKey, systemImage name: SanFranciscoSymbolName) {
        self.init(titleKey, systemImage: name.rawValue)
    }
    
    /// Creates a label with a system icon image and a title generated from a
    /// string.
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
    public init<S: StringProtocol>(_ title: S, systemImage name: SanFranciscoSymbolName) {
        self.init(title, systemImage: name.rawValue)
    }
}
