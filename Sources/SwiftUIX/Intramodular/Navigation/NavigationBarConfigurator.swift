//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

struct NavigationBarConfigurator<Leading: View, Center: View, Trailing: View, LargeTrailing: View>: UIViewControllerRepresentable {
    class UIViewControllerType: UIViewController {
        weak var navigationBarLargeTitleView: UIView? = nil
        
        var navigationBarLargeTitleTrailingItemHostingController: UIHostingController<LargeTrailing>? = nil
        
        var leading: Leading?
        var center: Center?
        var trailing: Trailing?
        var largeTrailing: LargeTrailing?
        var largeTrailingAlignment: VerticalAlignment?
        var displayMode: NavigationBarItem.TitleDisplayMode?
        
        var hasMovedToParentOnce: Bool = false
        var isVisible: Bool = false
        
        override func willMove(toParent parent: UIViewController?) {
            if !hasMovedToParentOnce {
                updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
                
                hasMovedToParentOnce = true
            }
            
            super.willMove(toParent: parent)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            isVisible = true
            
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            navigationBarLargeTitleTrailingItemHostingController?.view.removeFromSuperview()
            navigationBarLargeTitleTrailingItemHostingController = nil
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            isVisible = false
            
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
        }
        
        func updateNavigationBar(viewController: UIViewController?) {
            guard let parent = viewController else {
                return
            }
            
            #if os(iOS) || targetEnvironment(macCatalyst)
            if let displayMode = displayMode {
                switch displayMode {
                    case .automatic:
                        parent.navigationItem.largeTitleDisplayMode = .automatic
                    case .inline:
                        parent.navigationItem.largeTitleDisplayMode = .never
                    case .large:
                        parent.navigationItem.largeTitleDisplayMode = .always
                    @unknown default:
                        parent.navigationItem.largeTitleDisplayMode = .automatic
                }
            }
            #endif
            
            if let leading = leading {
                if !(leading is EmptyView) {
                    if parent.navigationItem.leftBarButtonItem == nil {
                        parent.navigationItem.leftBarButtonItem = .init(customView: UIHostingView(rootView: leading))
                    } else if let view = parent.navigationItem.leftBarButtonItem?.customView as? UIHostingView<Leading> {
                        view.rootView = leading
                    } else {
                        parent.navigationItem.leftBarButtonItem?.customView = UIHostingView(rootView: leading)
                    }
                } else {
                    parent.navigationItem.leftBarButtonItem = nil
                }
            } else {
                parent.navigationItem.leftBarButtonItem = nil
            }
            
            if let center = center {
                if !(center is EmptyView) {
                    if let view = parent.navigationItem.titleView as? UIHostingView<Center> {
                        view.rootView = center
                    } else {
                        parent.navigationItem.titleView = UIHostingView(rootView: center)
                    }
                } else {
                    parent.navigationItem.titleView = nil
                }
            } else {
                parent.navigationItem.titleView = nil
            }
            
            if let trailing = trailing {
                if !(trailing is EmptyView) {
                    if parent.navigationItem.rightBarButtonItem == nil {
                        parent.navigationItem.rightBarButtonItem = .init(customView: UIHostingView(rootView: trailing))
                    } else if let view = parent.navigationItem.rightBarButtonItem?.customView as? UIHostingView<Trailing> {
                        view.rootView = trailing
                    } else {
                        parent.navigationItem.rightBarButtonItem?.customView = UIHostingView(rootView: trailing)
                    }
                } else {
                    parent.navigationItem.rightBarButtonItem = nil
                }
            } else {
                parent.navigationItem.rightBarButtonItem = nil
            }
            
            parent.navigationItem.leftBarButtonItem?.customView?.sizeToFit()
            parent.navigationItem.titleView?.sizeToFit()
            parent.navigationItem.rightBarButtonItem?.customView?.sizeToFit()
            
            if let largeTrailing = largeTrailing, !(largeTrailing is EmptyView), isVisible {
                guard let navigationBar = self.navigationController?.navigationBar else {
                    return
                }
                
                guard let _UINavigationBarLargeTitleView = NSClassFromString("_" + "UINavigationBar" + "LargeTitleView") else {
                    return
                }
                
                for subview in navigationBar.subviews {
                    if subview.isKind(of: _UINavigationBarLargeTitleView.self) {
                        navigationBarLargeTitleView = subview
                    }
                }
                
                if let navigationBarLargeTitleView = navigationBarLargeTitleView {
                    if let hostingController = navigationBarLargeTitleTrailingItemHostingController, hostingController.view.superview == navigationBarLargeTitleView {
                        hostingController.rootView = largeTrailing
                    } else {
                        let hostingController = UIHostingController(rootView: largeTrailing)
                        
                        hostingController.view.backgroundColor = .clear
                        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                        
                        navigationBarLargeTitleView.addSubview(hostingController.view)
                        
                        NSLayoutConstraint.activate([
                            hostingController.view.trailingAnchor.constraint(
                                equalTo: navigationBarLargeTitleView.layoutMarginsGuide.trailingAnchor
                            )
                        ])
                        
                        switch (largeTrailingAlignment ?? .center) {
                            case .top:
                                NSLayoutConstraint.activate([
                                    hostingController.view.topAnchor.constraint(
                                        equalTo: navigationBarLargeTitleView.topAnchor
                                    )
                                ])
                            case .center:
                                NSLayoutConstraint.activate([
                                    hostingController.view.centerYAnchor.constraint(
                                        equalTo: navigationBarLargeTitleView.centerYAnchor
                                    )
                                ])
                            case .bottom:
                                NSLayoutConstraint.activate([
                                    hostingController.view.bottomAnchor.constraint(
                                        equalTo: navigationBarLargeTitleView.bottomAnchor
                                    )
                                ])
                            default:
                                NSLayoutConstraint.activate([
                                    hostingController.view.centerYAnchor.constraint(
                                        equalTo: navigationBarLargeTitleView.centerYAnchor
                                    )
                                ])
                        }
                        
                        self.navigationBarLargeTitleTrailingItemHostingController = hostingController
                    }
                }
            } else {
                self.navigationBarLargeTitleTrailingItemHostingController?.view.removeFromSuperview()
                self.navigationBarLargeTitleTrailingItemHostingController = nil
            }
        }
    }
    
    let leading: Leading
    let center: Center
    let trailing: Trailing
    let largeTrailing: LargeTrailing
    let largeTrailingAlignment: VerticalAlignment?
    let displayMode: NavigationBarItem.TitleDisplayMode?
    
    init(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        largeTrailing: LargeTrailing,
        largeTrailingAlignment: VerticalAlignment? = nil,
        displayMode: NavigationBarItem.TitleDisplayMode?
    ) {
        self.leading = leading
        self.center = center
        self.trailing = trailing
        self.largeTrailing = largeTrailing
        self.largeTrailingAlignment = largeTrailingAlignment
        self.displayMode = displayMode
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init()
    }
    
    func updateUIViewController(
        _ viewController: UIViewControllerType,
        context: Context
    ) {
        viewController.displayMode = displayMode
        viewController.leading = leading
        viewController.center = center
        viewController.trailing = trailing
        viewController.largeTrailing = largeTrailing
        viewController.largeTrailingAlignment = largeTrailingAlignment
        
        viewController.updateNavigationBar(viewController: viewController.navigationController?.topViewController)
    }
    
    static func dismantleUIViewController(
        _ uiViewController: UIViewControllerType,
        coordinator: Coordinator
    ) {
        uiViewController.largeTrailingAlignment = nil
        
        uiViewController.updateNavigationBar(viewController: uiViewController.navigationController?.topViewController)
    }
}

extension View {
    public func navigationBarItems<Leading: View, Center: View, Trailing: View>(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode? = .automatic
    ) -> some View {
        background(
            NavigationBarConfigurator(
                leading: leading,
                center: center,
                trailing: trailing,
                largeTrailing: EmptyView(),
                displayMode: displayMode
            )
        )
    }
        
    public func navigationBarItems<Leading: View, Center: View>(
        leading: Leading,
        center: Center,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(
            leading: leading,
            center: center,
            trailing: EmptyView(),
            displayMode: displayMode
        )
    }
    
    public func navigationBarTitleView<V: View>(
        _ center: V,
        displayMode: NavigationBarItem.TitleDisplayMode
    ) -> some View {
        navigationBarItems(
            leading: EmptyView(),
            center: center,
            trailing: EmptyView(),
            displayMode: displayMode
        )
    }
    
    public func navigationBarTitleView<V: View>(
        _ center: V
    ) -> some View {
        withEnvironmentValue(\.presenter) { presenter in
            navigationBarItems(
                leading: EmptyView(),
                center: center.environment(\.presenter, presenter),
                trailing: EmptyView(),
                displayMode: .automatic
            )
        }
    }
    
    public func navigationBarItems<Center: View, Trailing: View>(
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(
            leading: EmptyView(),
            center: center,
            trailing: trailing,
            displayMode: displayMode
        )
    }
}

extension View {
    @available(tvOS, unavailable)
    public func navigationBarLargeTitleItems<Trailing: View>(
        trailing: Trailing,
        alignment: VerticalAlignment? = nil,
        displayMode: NavigationBarItem.TitleDisplayMode? = .large
    ) -> some View {
        background(
            NavigationBarConfigurator(
                leading: EmptyView(),
                center: EmptyView(),
                trailing: EmptyView(),
                largeTrailing: trailing.font(.largeTitle),
                largeTrailingAlignment: alignment,
                displayMode: displayMode
            )
        )
    }

    /// Set a custom view for the navigation bar's large view mode.
    @available(tvOS, unavailable)
    public func navigationBarLargeTitle<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        background {
            _NavigationBarLargeTitleViewConfigurator(content: content())
                .frameZeroClipped()
                .accessibility(hidden: true)
        }
    }
}

// MARK: - Auxiliary

struct _NavigationBarLargeTitleViewConfigurator<Content: View>: UIViewControllerRepresentable {
    private let content: Content
    
    init(content: Content) {
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType(content: content)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.contentHostingController.mainView = content
    }
    
    class UIViewControllerType: UIViewController {
        let contentHostingController: CocoaHostingController<Content>
        
        private weak var navigationBarLargeTitleView: UIView?
        
        init(content: Content) {
            self.contentHostingController = .init(mainView: content)
            
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            guard contentHostingController.view.superview == nil else {
                return
            }
            
            guard
                let navigationBar = navigationController?.navigationBar,
                let navigationBarLargeTitleViewClass = NSClassFromString("_UINavigationBarLargeTitleView"),
                let navigationBarLargeTitleView = navigationBar.subviews.first(where: { $0.isKind(of: navigationBarLargeTitleViewClass.self) })
            else {
                return
            }
            
            self.navigationBarLargeTitleView = navigationBarLargeTitleView
            
            navigationBarLargeTitleView.subviews.forEach {
                $0.isHidden = true
            }
            
            contentHostingController.view.backgroundColor = .clear
            contentHostingController.view.clipsToBounds = true
            contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            navigationBar.addSubview(contentHostingController.view)
            
            NSLayoutConstraint.activate([
                contentHostingController.view.leadingAnchor.constraint(equalTo: navigationBarLargeTitleView.leadingAnchor),
                contentHostingController.view.trailingAnchor.constraint(equalTo: navigationBarLargeTitleView.trailingAnchor),
                contentHostingController.view.bottomAnchor.constraint(equalTo: navigationBarLargeTitleView.bottomAnchor),
                contentHostingController.view.heightAnchor.constraint(equalTo: navigationBarLargeTitleView.heightAnchor)
            ])
            
            contentHostingController.view.setNeedsLayout()
            contentHostingController.view.layoutSubviews()
            
            super.viewWillAppear(animated)
        }
        
        deinit {
            contentHostingController.view.removeFromSuperview()
            
            navigationBarLargeTitleView?.subviews.forEach {
                $0.isHidden = false
            }
        }
    }
}

#endif
