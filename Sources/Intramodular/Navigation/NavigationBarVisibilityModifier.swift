//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

final class IsNavigationBarVisible: TakeLastPreferenceKey<Bool> {
    
}

private struct NavigationBarVisibilityModifier: ViewModifier {
    @Environment(\.isNavigationBarHidden) var isNavigationBarHidden
    
    let isVisible: Bool
    
    @State var _isVisible: Bool? = nil
    
    var isHidden: Bool {
        !(_isVisible ?? false)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if isHidden {
                ZeroSizeView()
                    .navigationBarTitle("")
            }
            
            content
                .navigationBarHidden(isHidden)
                .onAppear(perform: {
                    DispatchQueue.main.async {
                        self._isVisible = !self.isVisible
                        
                        DispatchQueue.main.async {
                            self._isVisible = self.isVisible
                        }
                    }
                })
                .preference(key: IsNavigationBarVisible.self, value: isVisible)
        }
    }
}

// MARK: - API -

extension View {
    public func navigationBarVisible(_ isVisible: Bool) -> some View {
        modifier(NavigationBarVisibilityModifier(isVisible: isVisible))
    }
}

#endif
