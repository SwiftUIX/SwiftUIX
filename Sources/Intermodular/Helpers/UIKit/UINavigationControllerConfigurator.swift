//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct UINavigationControllerConfigurator: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @usableFromInline
    let configure: (UINavigationController) -> Void
    
    @usableFromInline
    init(configure: @escaping (UINavigationController) -> Void) {
        self.configure = configure
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.nearestNavigationController.map(configure)
    }
}

// MARK: - API -

extension View {
    @usableFromInline
    func configureUINavigationController(
        _ configure: @escaping (UINavigationController) -> Void
    ) -> some View {
        background(UINavigationControllerConfigurator(configure: configure))
    }
    
    @usableFromInline
    func configureUINavigationBar(
        _ configure: @escaping (UINavigationBar) -> Void
    ) -> some View {
        configureUINavigationController { navigationController in
            DispatchQueue.main.async {
                configure(navigationController.navigationBar)
            }
        }
    }
}

extension View {
    /// Configures the translucency of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - isTranslucent: A Boolean value that indicates whether the navigation bar is translucent.
    @inlinable
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
    @inlinable
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
    @inlinable
    public func navigationBarColor(_ color: Color) -> some View {
        configureUINavigationBar { navigationBar in
            navigationBar.backgroundColor = color.toUIColor()
            navigationBar.barTintColor = color.toUIColor()
        }
    }
}

#endif
