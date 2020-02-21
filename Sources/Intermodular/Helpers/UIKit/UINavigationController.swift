//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

fileprivate struct UINavigationControllerConfigurator: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController
    
    let configure: (UINavigationController) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.navigationController.map(configure)
    }
}

// MARK: - API -

extension View {
    func configureCocoaNavigationController(
        _ configure: @escaping (UINavigationController) -> Void
    ) -> some View {
        background(UINavigationControllerConfigurator(configure: configure))
    }
    
    func configureCocoaNavigationBar(
        _ configure: @escaping (UINavigationBar) -> Void
    ) -> some View {
        EnvironmentValueAccessView(\.isNavigationBarHidden) { isNavigationBarHidden in
            self.configureCocoaNavigationController { navigationController in
                if (isNavigationBarHidden ?? false) != true {
                    DispatchQueue.main.async {
                        configure(navigationController.navigationBar)
                    }
                }
            }
        }
    }
}

#endif
