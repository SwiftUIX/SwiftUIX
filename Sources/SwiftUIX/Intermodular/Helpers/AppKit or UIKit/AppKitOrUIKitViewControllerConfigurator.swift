//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A modifier that can be applied to a view, exposing access to the parent `UIViewController`.
@usableFromInline
struct AppKitOrUIKitViewControllerConfigurator: UIViewControllerRepresentable {
    @usableFromInline
    struct Configuration {
        @usableFromInline
        var hidesBottomBarWhenPushed: Bool?
        
        @usableFromInline
        init() {
            
        }
    }
    
    @usableFromInline
    class UIViewControllerType: UIViewController {
        var configuration: Configuration {
            didSet {
                parent?.configure(with: configuration)
            }
        }
        
        init(configuration: Configuration) {
            self.configuration = configuration
            
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMove(toParent parent: UIViewController?) {
            parent?.configure(with: configuration)
            
            super.didMove(toParent: parent)
        }
    }
    
    @usableFromInline
    var configuration: Configuration
    
    @usableFromInline
    init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }
    
    @usableFromInline
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(configuration: configuration)
    }
    
    @usableFromInline
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.configuration = configuration
    }
    
    @usableFromInline
    func configure(_ transform: (inout Configuration) -> Void) -> Self {
        then({ transform(&$0.configuration) })
    }
}

// MARK: - Auxiliary

extension UIViewController {
    /// Configures this view controller with a given configuration.
    @inlinable
    func configure(with configuration: AppKitOrUIKitViewControllerConfigurator.Configuration) {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if let newValue = configuration.hidesBottomBarWhenPushed {
            hidesBottomBarWhenPushed = newValue
        }
        #endif
    }
}


extension View {
    /// Configures this view's parent `UIViewController`.
    @inlinable
    func configureUIViewController(
        _ transform: (inout AppKitOrUIKitViewControllerConfigurator.Configuration) -> Void
    ) -> some View {
        background(AppKitOrUIKitViewControllerConfigurator().configure(transform))
    }
}

#endif
