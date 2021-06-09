//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension View {
    @inlinable
    public func _configureUINavigationController(
        _ configure: @escaping (UINavigationController) -> Void
    ) -> some View {
        onAppKitOrUIKitViewControllerResolution { viewController in
            DispatchQueue.main.async {
                guard let navigationController = viewController.navigationController else {
                    return
                }
                
                configure(navigationController)
            }
        } onAppear: { viewController in
            DispatchQueue.main.async {
                guard let navigationController = viewController.navigationController else {
                    return
                }
                
                configure(navigationController)
            }
        }
    }
    
    @inlinable
    public func _configureUINavigationBar(
        _ configure: @escaping (UINavigationBar) -> Void
    ) -> some View {
        _configureUINavigationController {
            configure($0.navigationBar)
        }
    }
}

extension View {
    /// Configures the color of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - color: The color to use for the navigation bar.
    @inlinable
    public func navigationBarColor(_ color: Color) -> some View {
        _configureUINavigationBar { navigationBar in
            navigationBar.backgroundColor = color.toUIColor()
            navigationBar.barTintColor = color.toUIColor()
        }
    }
    
    /// Configures the translucency of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - isTranslucent: A Boolean value that indicates whether the navigation bar is translucent.
    @inlinable
    public func navigationBarTranslucent(_ translucent: Bool) -> some View {
        _configureUINavigationBar { navigationBar in
            navigationBar.isTranslucent = translucent
        }
    }
    
    @inlinable
    @available(iOS, deprecated: 13.0, renamed: "navigationBarTranslucent(_:)")
    public func navigationBarIsTranslucent(_ isTranslucent: Bool) -> some View {
        navigationBarTranslucent(isTranslucent)
    }
    
    /// Configures the transparency of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - isTransparent: A Boolean value that indicates whether the navigation bar is transparent.
    @inlinable
    public func navigationBarTransparent(_ transparent: Bool) -> some View {
        _configureUINavigationBar { navigationBar in
            navigationBar.isDefaultTransparent = transparent
        }
    }
    
    @inlinable
    @available(iOS, deprecated: 13.0, renamed: "navigationBarTransparent(_:)")
    public func navigationBarIsTransparent(_ isTransparent: Bool) -> some View {
        navigationBarTransparent(isTransparent)
    }
}

extension View {
    @available(tvOS, unavailable)
    @ViewBuilder
    public func _inlineNavigationBar() -> some View {
        if #available(iOS 14.0, tvOS 14.0, *) {
            self
                ._configureUINavigationBar { navigationBar in
                    navigationBar.prefersLargeTitles = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        navigationBar.prefersLargeTitles = false
                    }
                    
                    navigationBar.prefersLargeTitles = false
                }
                .onAppKitOrUIKitViewControllerResolution { viewController in
                    viewController.navigationController?.navigationBar.prefersLargeTitles = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        viewController.navigationController?.navigationBar.prefersLargeTitles = false
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        } else {
            self
                ._configureUINavigationBar { navigationBar in
                    navigationBar.prefersLargeTitles = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        navigationBar.prefersLargeTitles = false
                    }
                    
                    navigationBar.prefersLargeTitles = false
                }
                .onAppKitOrUIKitViewControllerResolution { viewController in
                    viewController.navigationController?.navigationBar.prefersLargeTitles = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        viewController.navigationController?.navigationBar.prefersLargeTitles = false
                    }
                }
        }
    }
}

#endif
