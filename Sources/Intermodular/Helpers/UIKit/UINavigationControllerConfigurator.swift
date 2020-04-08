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

#endif
