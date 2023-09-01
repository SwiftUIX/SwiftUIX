//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)
extension View {
    public func sidebarListStyleIfAvailable() -> some View {
        listStyle(SidebarListStyle())
    }
}
#elseif targetEnvironment(macCatalyst)
extension View {
    public func sidebarListStyleIfAvailable() -> some View {
        if #available(macCatalyst 14.0, *) {
            listStyle(SidebarListStyle())
        } else {
            self
        }
    }
}
#else
extension View {
    public func sidebarListStyleIfAvailable() -> some View {
        self
    }
}
#endif
