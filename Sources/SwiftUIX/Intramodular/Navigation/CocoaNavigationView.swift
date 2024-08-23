//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public struct CocoaNavigationView<Content: View>: View {
    private let content: Content
    private var configuration = _Body.Configuration()
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public init(navigationBarHidden: Bool, @ViewBuilder content: () -> Content) {
        self.init(content: content)
        
        self.configuration.isNavigationBarHidden = navigationBarHidden
    }
    
    public var body: some View {
        _Body(content: content, configuration: configuration)
            .edgesIgnoringSafeArea(.all)
    }
    
    public func navigationBarHidden(_ hidden: Bool) -> some View {
        then({ $0.configuration.isNavigationBarHidden = hidden })
    }
}

extension CocoaNavigationView {
    struct _Body: UIViewControllerRepresentable {
        struct Configuration {
            var isNavigationBarHidden: Bool = false
        }
        
        class UIViewControllerType: UINavigationController, UIGestureRecognizerDelegate {
            var configuration = Configuration() {
                didSet {
                    if configuration.isNavigationBarHidden != oldValue.isNavigationBarHidden {
                        if configuration.isNavigationBarHidden != isNavigationBarHidden {
                            self.setNavigationBarHidden(configuration.isNavigationBarHidden, animated: true)
                        }
                        
                        if configuration.isNavigationBarHidden {
                            interactivePopGestureRecognizer?.delegate = self
                        } else if interactivePopGestureRecognizer?.delegate === self {
                            interactivePopGestureRecognizer?.delegate = nil
                        }
                    }
                }
            }
            
            override var isNavigationBarHidden: Bool {
                get {
                    super.isNavigationBarHidden
                } set {
                    guard !(configuration.isNavigationBarHidden && !newValue) else {
                        return
                    }
                    
                    super.isNavigationBarHidden = newValue
                }
            }
            
            override open func viewDidLoad() {
                super.viewDidLoad()
                
                if configuration.isNavigationBarHidden {
                    interactivePopGestureRecognizer?.delegate = self
                }
            }
            
            override func viewWillAppear(_ animated: Bool) {
                self.view.backgroundColor = nil
                
                super.viewWillAppear(animated)
                
                setNavigationBarHidden(configuration.isNavigationBarHidden, animated: false)
            }
            
            override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
                guard hidden != isNavigationBarHidden else {
                    return
                }
                
                super.setNavigationBarHidden(configuration.isNavigationBarHidden, animated: animated)
            }
            
            override func pushViewController(_ viewController: UIViewController, animated: Bool) {
                super.pushViewController(viewController, animated: true)
            }
            
            @objc public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
                let result = viewControllers.count > 1
                
                if result {
                    view.window?.endEditing(true)
                }
                
                return result
            }
        }
        
        let content: Content
        let configuration: Configuration
        
        func makeUIViewController(context: Context) -> UIViewControllerType {
            let viewController = UIViewControllerType()
            
            viewController.setViewControllers([CocoaHostingController(mainView: _ChildContainer(parent: viewController, rootView: content))], animated: false)
            
            viewController.configuration = configuration
            
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            uiViewController.configuration = configuration
            
            if let controller = uiViewController.viewControllers.first as? CocoaHostingController<_ChildContainer> {
                controller.mainView = .init(parent: uiViewController, rootView: content)
            }
        }
    }
    
    struct _ChildContainer: View {
        weak var parent: UINavigationController?
        
        var rootView: AnyView
        
        init<T: View>(parent: UINavigationController, rootView: T) {
            self.parent = parent
            self.rootView = rootView.eraseToAnyView()
        }
        
        var body: some View {
            rootView
                .environment(\.navigator, parent.map(_UINavigationControllerNavigatorAdaptorBox.init))
        }
    }
}

#endif


/// Useful for suppressing deprecation warnings with `NavigationView`.
///
/// ```swift
///
/// _NavigationView {
///    List {
///        NavigationLink(_isActive: ...) {
///            // <your destination view>
///        } label: {
///            // <your label view>
///        }
///    }
///
///    Text("Hello, Placeholder!")
/// }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
@frozen
@_documentation(visibility: internal)
public struct _NavigationView<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        NavigationView {
            content
        }
    }
}

extension NavigationLink {
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
    public init(
        _isActive isActive: Binding<Bool>,
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            isActive: isActive,
            destination: destination,
            label: label
        )
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
    public init<V: Hashable>(
        _tag tag: V,
        selection: Binding<V>,
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            tag: tag,
            selection: selection._asOptional(defaultValue: tag),
            destination: destination,
            label: label
        )
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
    public init<V: Hashable>(
        _ title: String,
        _tag tag: V,
        selection: Binding<V>,
        @ViewBuilder destination: () -> Destination
    ) where Label == Text {
        self.init(
            title,
            tag: tag,
            selection: selection._asOptional(defaultValue: tag),
            destination: destination
        )
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
    public init(
        _ title: String,
        _isActive isActive: Binding<Bool>,
        @ViewBuilder destination: () -> Destination
    ) where Label == Text {
        self.init(
            title,
            isActive: isActive,
            destination: destination
        )
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
    public init(
        _ title: String,
        _isActive isActive: Binding<Bool>,
        destination: Destination
    ) where Label == Text {
        self.init(
            title,
            isActive: isActive,
            destination: { destination }
        )
    }
}
