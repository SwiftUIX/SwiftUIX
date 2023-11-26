//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
extension Label where Title == Text {
    /// Creates a label with a system icon image and a title generated from a
    /// localized string.
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder icon: () -> Icon) {
        self.init(title: { Text(titleKey) }, icon: icon)
    }
    
    /// Creates a label with a system icon image and a title generated from a
    /// string.
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
    public init<S: StringProtocol>(_ title: S,  @ViewBuilder icon: () -> Icon) {
        self.init(title: { Text(title) }, icon: icon)
    }
}

@available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
extension Label where Title == Text, Icon == Image {
    /// Creates a label with a system icon image and a title generated from a
    /// localized string.
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
    public init(_ titleKey: LocalizedStringKey, systemImage name: SFSymbolName) {
        self.init(titleKey, systemImage: name.rawValue)
    }
    
    /// Creates a label with a system icon image and a title generated from a
    /// string.
    @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
    public init<S: StringProtocol>(_ title: S, systemImage name: SFSymbolName) {
        self.init(title, systemImage: name.rawValue)
    }
}
