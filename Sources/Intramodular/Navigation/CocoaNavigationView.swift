//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _CocoaNavigatedContent<Content: View>: View {
    class HostingController: UIHostingController<_CocoaNavigatedContent<Content>> {
        var navigator: CocoaNavigationViewNavigator! {
            didSet {
                rootView.navigator = navigator
            }
        }
        
        init(rootView: Content, navigator: CocoaNavigationViewNavigator? = nil) {
            self.navigator = navigator
            
            super.init(rootView: .init(content: rootView, navigator: navigator))
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var content: Content
    var navigator: CocoaNavigationViewNavigator?
    
    init(content: Content, navigator: CocoaNavigationViewNavigator?) {
        self.content = content
        self.navigator = navigator
    }
    
    var body: some View {
        content.environment(\.navigator, navigator)
    }
}

final class CocoaNavigationViewNavigator: Navigator {
    private var base: UINavigationController!
    
    init(base: UINavigationController) {
        self.base = base
    }
    
    func push<V: View>(_ view: V) {
        base.pushViewController(_CocoaNavigatedContent.HostingController(rootView: view, navigator: self), animated: true)
    }
    
    func pop() {
        base.popViewController(animated: true)
    }
}

public struct CocoaNavigationView<Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = _UINavigationController
    
    public final class _UINavigationController: UINavigationController {
        let _rootViewController: _CocoaNavigatedContent<Content>.HostingController
        var rootView: Content {
            get {
                _rootViewController.rootView.content
            } set {
                _rootViewController.rootView.content = newValue
            }
        }
        
        init(content: Content) {
            self._rootViewController = .init(rootView: content)
            
            super.init(rootViewController: _rootViewController)
            
            _rootViewController.navigator = .init(base: self)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        _UINavigationController(content: content)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.rootView = content
    }
}

#endif
