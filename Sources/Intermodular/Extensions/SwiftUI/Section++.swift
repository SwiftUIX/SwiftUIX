//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Section {
    public var header: Parent {
        unsafeBitCast(self, to: (Parent, Content, Footer).self).0
    }
    
    public var content: Content {
        unsafeBitCast(self, to: (Parent, Content, Footer).self).1
    }
    
    public var footer: Footer {
        unsafeBitCast(self, to: (Parent, Content, Footer).self).2
    }
}

extension Section where Parent == Text, Content: View, Footer == EmptyView {
    @_disfavoredOverload
    public init<S: StringProtocol>(_ header: S, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), content: content)
    }
    
    @_disfavoredOverload
    public init(_ header: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), content: content)
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(header: S, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), content: content)
    }
}

extension Section where Parent == Text, Content: View, Footer == Text {
    public init<S: StringProtocol>(
        header: S,
        footer: S,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: Text(header), footer: Text(footer), content: content)
    }
}
