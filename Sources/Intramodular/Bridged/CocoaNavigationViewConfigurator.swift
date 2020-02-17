//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

fileprivate struct CocoaNavigationViewConfigurator: UIViewControllerRepresentable {
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
        background(CocoaNavigationViewConfigurator(configure: configure))
    }
    
    func configureCocoaNavigationBar(
        _ configure: @escaping (UINavigationBar) -> Void
    ) -> some View {
        configureCocoaNavigationController {
            configure($0.navigationBar)
        }
    }
}

#endif
