//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if canImport(SensitiveContentAnalysis)
@available(iOS 14.0, macOS 11.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension Menu {
    public init(
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) where Label == Image {
        let content = content()
        
        self.init(content: { content }) {
            Image(systemName: systemImage)
        }
    }
    
    public init(
        systemImage: SFSymbol,
        @ViewBuilder content: () -> Content
    ) where Label == Image {
        self.init(systemImage: systemImage.rawValue, content: content)
    }
}
#elseif !os(tvOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Menu {
    public init(
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) where Label == Image {
        let content = content()
        
        self.init(content: { content }) {
            Image(systemName: systemImage)
        }
    }
    
    public init(
        systemImage: SFSymbol,
        @ViewBuilder content: () -> Content
    ) where Label == Image {
        self.init(systemImage: systemImage.rawValue, content: content)
    }
}
#endif
