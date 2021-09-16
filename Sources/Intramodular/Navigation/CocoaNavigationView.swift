//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

public struct CocoaNavigationView<Content: View>: View {
    private let content: Content
    private var configuration = _Body.Configuration()
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        _Body(content: content, configuration: configuration)
            .edgesIgnoringSafeArea(.all)
    }
    
    public func navigationBarHidden(_ hidden: Bool) -> some View {
        then({ $0.configuration.navigationBarHidden = hidden })
    }
}

extension CocoaNavigationView {
    struct _Body: UIViewControllerRepresentable {
        struct Configuration {
            var navigationBarHidden: Bool = false
        }
        
        class UIViewControllerType: UINavigationController {
            var configuration = Configuration() {
                didSet {
                    if configuration.navigationBarHidden != oldValue.navigationBarHidden {
                        if configuration.navigationBarHidden != isNavigationBarHidden {
                            self.setNavigationBarHidden(configuration.navigationBarHidden, animated: true)
                        }
                    }
                }
            }
            
            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                setNavigationBarHidden(configuration.navigationBarHidden, animated: false)
            }
            
            override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
                guard hidden != isNavigationBarHidden else {
                    return
                }
                
                super.setNavigationBarHidden(configuration.navigationBarHidden, animated: animated)
            }
        }
        
        let content: Content
        let configuration: Configuration
        
        func makeUIViewController(context: Context) -> UIViewControllerType {
            let viewController = UIViewControllerType(rootViewController: CocoaHostingController(mainView: content))
            
            viewController.configuration = configuration
            
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            uiViewController.configuration = configuration
            
            if let controller = uiViewController.viewControllers.first as? CocoaHostingController<Content> {
                controller.mainView = content
            }
        }
    }
}

#endif
