//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

final class IsNavigationBarVisible: TakeLastPreferenceKey<Bool> {
    
}

public struct NavigationBarVisibilityModifier: ViewModifier {
    let isVisible: Bool?
    
    public var isHidden: Bool {
        !(isVisible ?? true)
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationBarHidden(self.isHidden)
            .configureCocoaNavigationController({ controller in
                if let isVisible = self.isVisible {
                    if controller.isNavigationBarHidden != !isVisible {
                        controller.setNavigationBarHidden(!isVisible, animated: true)
                    }
                }
            })
            .preference(key: IsNavigationBarVisible.self, value: isVisible)
    }
}

// MARK: - API -

extension View {
    public func navigationBarVisible(_ isVisible: Bool) -> some View {
        modifier(NavigationBarVisibilityModifier(isVisible: isVisible))
    }
}

#endif
