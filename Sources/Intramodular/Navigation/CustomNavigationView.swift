//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CustomNavigationView<Content: View>: View {
    private let content: Content
    
    @State private var isNavigationBarVisible: Bool? = nil
    
    public var isNavigationBarHidden: Bool? {
        guard let isNavigationBarVisible = isNavigationBarVisible else {
            return nil
        }
        
        return !isNavigationBarVisible
    }
        
    public var body: some View {
        NavigationView {
            content
                .onPreferenceChange(IsNavigationBarVisible.self, perform: {
                    self.isNavigationBarVisible = $0
                })
                .environment(\.isNavigationBarHidden, isNavigationBarHidden)
        }
    }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

final class IsNavigationBarVisible: TakeLastPreferenceKey<Bool> {
    
}

extension View {
    /// Configures the translucency of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - isTranslucent: A Boolean value that indicates whether the navigation bar is translucent.
    public func navigationBarIsTranslucent(_ isTranslucent: Bool) -> some View {
        configureUINavigationBar { navigationBar in
            navigationBar.isTranslucent = isTranslucent
        }
    }
    
    /// Configures the transparency of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - isTransparent: A Boolean value that indicates whether the navigation bar is transparent.
    public func navigationBarIsTransparent(_ isTransparent: Bool) -> some View {
        configureUINavigationBar { navigationBar in
            navigationBar.isDefaultTransparent = isTransparent
        }
    }
    
    /// Configures the color of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - color: The color to use for the navigation bar.
    public func navigationBarColor(_ color: Color) -> some View {
        configureUINavigationBar { navigationBar in
            navigationBar.backgroundColor = color.toUIColor()
            navigationBar.barTintColor = color.toUIColor()
        }
    }
}

#endif
