//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

final class IsNavigationBarVisibile: TakeLastPreferenceKey<Bool> {
    
}

struct NavigationBarVisibilityModifier: ViewModifier {
    @State private var isVisible: Bool?
    
    func body(content: Content) -> some View {
        isVisible.ifSome { isVisible in
            content
                .navigationBarHidden(!isVisible)
                .configureCocoaNavigationController({ controller in
                    DispatchQueue.main.async {
                        controller.isNavigationBarHidden = !isVisible
                    }
                })
        }.else(content).onPreferenceChange(IsNavigationBarVisibile.self) {
            self.isVisible = $0
        }
    }
}

extension View {
    public func hideNavigationBar() -> some View {
        preference(key: IsNavigationBarVisibile.self, value: false)
            .modifier(NavigationBarVisibilityModifier())
    }
    
    public func showNavigationBar() -> some View {
        preference(key: IsNavigationBarVisibile.self, value: true)
            .modifier(NavigationBarVisibilityModifier())
    }
}

#endif
