//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    public func sidebarListStyleIfAvailable() -> some View {
        #if swift(>=5.3)
        #if os(macOS)
        return listStyle(SidebarListStyle())
        #elseif targetEnvironment(macCatalyst)
        if #available(macCatalyst 14.0, *) {
            return AnyView(listStyle(SidebarListStyle()))
        } else {
            return AnyView(self)
        }
        #else
        return self
        #endif
        #else
        return self
        #endif
    }
}
