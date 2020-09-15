//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    #if (os(iOS) || os(watchOS) || os(tvOS)) && !targetEnvironment(macCatalyst)
    public func sidebarListStyleIfAvailable() -> some View {
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
    }
    #else
    public func sidebarListStyleIfAvailable() -> some View {
        #if os(macOS)
        return listStyle(SidebarListStyle())
        #else
        return self
        #endif
    }
    #endif
}
