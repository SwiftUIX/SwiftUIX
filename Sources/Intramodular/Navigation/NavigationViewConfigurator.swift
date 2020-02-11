//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

fileprivate struct NavigationViewConfigurator: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController
    
    let configure: (UINavigationController) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.navigationController.map(configure)
    }
}

extension View {
    fileprivate func configureCocoaNavigationController(
        _ configure: @escaping (UINavigationController) -> Void
    ) -> some View {
        background(NavigationViewConfigurator(configure: configure))
    }
    
    fileprivate func configureCocoaNavigationBar(
        _ configure: @escaping (UINavigationBar) -> Void
    ) -> some View {
        configureCocoaNavigationController {
            configure($0.navigationBar)
        }
    }
    
    /// Configures the translucency of the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - isTranslucent: A Boolean value that indicates whether the navigation bar is translucent.
    public func navigationBarIsTranslucent(_ isTranslucent: Bool) -> some View {
        configureCocoaNavigationBar {
            $0.isTranslucent = isTranslucent
        }
    }
    
    public func navigationBarColor(_ color: Color) -> some View {
        configureCocoaNavigationBar {
            $0.backgroundColor = color.toUIColor()
        }
    }
}

final class IsNavigationBarVisibilePreferenceKey: TakeLastPreferenceKey<Bool> {
    
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
        }.else(content).onPreferenceChange(IsNavigationBarVisibilePreferenceKey.self) {
            self.isVisible = $0
        }
    }
}

extension View {
    public func hideNavigationBar() -> some View {
        preference(key: IsNavigationBarVisibilePreferenceKey.self, value: false)
            .modifier(NavigationBarVisibilityModifier())
    }
    
    public func showNavigationBar() -> some View {
        preference(key: IsNavigationBarVisibilePreferenceKey.self, value: true)
            .modifier(NavigationBarVisibilityModifier())
        
    }
}

#endif
