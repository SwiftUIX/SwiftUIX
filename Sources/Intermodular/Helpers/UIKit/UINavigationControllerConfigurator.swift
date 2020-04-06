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
        uiViewController.nearestNavigationController.map(configure)
    }
}

// MARK: - API -

extension View {
    func configureUINavigationController(
        _ configure: @escaping (UINavigationController) -> Void
    ) -> some View {
        background(UINavigationControllerConfigurator(configure: configure))
    }
    
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
