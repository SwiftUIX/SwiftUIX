//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

private struct HideNavigationBar: ViewModifier {
    @State var isNavigationBarHidden = false
        
    func body(content: Content) -> some View {
        ZStack {
            if isNavigationBarHidden {
                ZeroSizeView()
                    .navigationBarTitle("")
            }
            
            content
                .navigationBarHidden(isNavigationBarHidden)
                .onAppear(perform: {
                    self.isNavigationBarHidden = true
                })
                .onDisappear(perform: {
                    self.isNavigationBarHidden = false
                })
                .preference(key: IsNavigationBarVisible.self, value: !isNavigationBarHidden)
        }
    }
}

// MARK: - API -

extension View {
    public func hideNavigationBar() -> some View {
        modifier(HideNavigationBar())
    }
}

#endif
