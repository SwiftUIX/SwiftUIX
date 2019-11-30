//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct NavigationBarHider: ViewModifier {
    @DelayedState private var isHidden: Bool = false
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitle("")
            .navigationBarHidden(isHidden)
            .onAppear { self.isHidden = true }
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
