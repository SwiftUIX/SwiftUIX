//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct NavigationTitleViewConfigurator<Content: View>: UIViewControllerRepresentable {
    class UIViewControllerType: UIViewController {
        var titleView: Content {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var displayMode: NavigationBarItem.TitleDisplayMode {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        init(titleView: Content, displayMode: NavigationBarItem.TitleDisplayMode) {
            self.titleView = titleView
            self.displayMode = displayMode
            
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func willMove(toParent parent: UIViewController?) {
            updateNavigationBar(parent: parent)
            
            super.willMove(toParent: parent)
        }
        
        private func updateNavigationBar(parent: UIViewController?) {
            guard let parent = parent else {
                return
            }
            
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
            
            if let view = parent.navigationItem.titleView as? UIHostingView<Content> {
                view.rootView = titleView
            } else {
                parent.navigationItem.titleView = UIHostingView(rootView: titleView)
            }
            
            parent.navigationItem.titleView?.sizeToFit()
        }
    }
    
    let titleView: Content
    let displayMode: NavigationBarItem.TitleDisplayMode
    
    init(titleView: Content, displayMode: NavigationBarItem.TitleDisplayMode) {
        self.displayMode = displayMode
        self.titleView = titleView
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(titleView: titleView, displayMode: displayMode)
    }
    
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.displayMode = displayMode
        viewController.titleView = titleView
    }
}

extension View {
    public func navigationBarTitleView<V: View>(
        _ titleView: V,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        background(NavigationTitleViewConfigurator(titleView: titleView, displayMode: displayMode))
    }
}
