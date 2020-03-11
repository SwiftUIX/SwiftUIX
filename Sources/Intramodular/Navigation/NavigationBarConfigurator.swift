//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

private struct NavigationBarConfigurator<Leading: View, Center: View, Trailing: View>: UIViewControllerRepresentable {
    class UIViewControllerType: UIViewController {
        var leading: Leading? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var center: Center? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var trailing: Trailing? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var displayMode: NavigationBarItem.TitleDisplayMode? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
                
        override func willMove(toParent parent: UIViewController?) {
            updateNavigationBar(parent: parent)
            
            super.willMove(toParent: parent)
        }
        
        private func updateNavigationBar(parent: UIViewController?) {
            guard let parent = parent else {
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
                }
            }
            
            if let center = center {
                if !(center is EmptyView) {
                    if let view = parent.navigationItem.titleView as? UIHostingView<Center> {
                        view.rootView = center
                    } else {
                        parent.navigationItem.titleView = UIHostingView(rootView: center)
                    }
                }
            }
            
            if let trailing = trailing{
                if !(trailing is EmptyView) {
                    if parent.navigationItem.rightBarButtonItem == nil {
                        parent.navigationItem.rightBarButtonItem = .init(customView: UIHostingView(rootView: trailing))
                    } else if let view = parent.navigationItem.rightBarButtonItem?.customView as? UIHostingView<Trailing> {
                        view.rootView = trailing
                    } else {
                        parent.navigationItem.rightBarButtonItem?.customView = UIHostingView(rootView: trailing)
                    }
                }
            }
            
            parent.navigationItem.leftBarButtonItem?.customView?.sizeToFit()
            parent.navigationItem.titleView?.sizeToFit()
            parent.navigationItem.rightBarButtonItem?.customView?.sizeToFit()
        }
    }
    
    let leading: Leading
    let center: Center
    let trailing: Trailing
    let displayMode: NavigationBarItem.TitleDisplayMode?
    
    init(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode?
    ) {
        self.leading = leading
        self.center = center
        self.trailing = trailing
        self.displayMode = displayMode
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init()
    }
    
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.displayMode = displayMode
        viewController.leading = leading
        viewController.center = center
        viewController.trailing = trailing
    }
}

extension View {
    public func navigationBarItems<Leading: View, Center: View, Trailing: View>(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode? = .automatic
    ) -> some View {
        background(NavigationBarConfigurator(leading: leading, center: center, trailing: trailing, displayMode: displayMode))
    }
    
    public func navigationBarItems<Leading: View, Center: View>(
        leading: Leading,
        center: Center,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(leading: leading, center: center, trailing: EmptyView(), displayMode: displayMode)
    }
    
    public func navigationBarTitleView<V: View>(
        _ center: V,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(leading: EmptyView(), center: center, trailing: EmptyView(), displayMode: displayMode)
    }
    
    public func navigationBarItems<Center: View, Trailing: View>(
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(leading: EmptyView(), center: center, trailing: trailing, displayMode: displayMode)
    }
}

#endif
