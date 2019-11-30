//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

struct UINavigationControllerConfigurator: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController
    
    private let configure: (UINavigationController) -> Void
    
    public init(configure: @escaping (UINavigationController) -> Void) {
        self.configure = configure
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.navigationController.map(configure)
    }
}

#endif
