//
// Copyright (c) Vatsal Manot
//

import SwiftUI

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
        systemImage: SFSymbolName,
        @ViewBuilder content: () -> Content
    ) where Label == Image {
        self.init(systemImage: systemImage.rawValue, content: content)
    }
}
