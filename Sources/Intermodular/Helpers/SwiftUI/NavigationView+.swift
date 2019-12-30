//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct NavigationBarHider: ViewModifier {
    @DelayedState private var isHidden: Bool = false
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitle(String())
            .navigationBarHidden(isHidden)
            .onAppear(perform: { self.isHidden = true })
    }
}

extension View {
    public func navigated() -> some View {
        NavigationView {
            self
        }
    }
    
    public func hideNavigationBar() -> some View {
        modifier(NavigationBarHider())
    }
}

#endif
