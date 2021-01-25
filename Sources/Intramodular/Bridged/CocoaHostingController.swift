//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: AppKitOrUIKitHostingController<CocoaHostingControllerContent<Content>>, CocoaController {
    #if os(iOS) || targetEnvironment(macCatalyst)
    override open var prefersStatusBarHidden: Bool {
        return false
    }
    #endif
    
    public let _presentationCoordinator: CocoaPresentationCoordinator
    
    override public var presentationCoordinator: CocoaPresentationCoordinator {
        return _presentationCoordinator
    }
    
    var _namedViewDescriptions: [ViewName: _NamedViewDescription] = [:]
    
    init(
        rootView: Content,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self._presentationCoordinator = presentationCoordinator
        
        super.init(
            rootView: .init(
                parent: nil,
                content: rootView,
                presentationCoordinator: presentationCoordinator
            )
        )
        
        presentationCoordinator.setViewController(self)
        
        self.rootView.parent = self
        
        if let rootView = rootView as? AnyPresentationView {
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            #if os(iOS) || targetEnvironment(macCatalyst)
            hidesBottomBarWhenPushed = rootView.hidesBottomBarWhenPushed
            #endif
            modalPresentationStyle = .init(rootView.presentationStyle)
            transitioningDelegate = rootView.presentationStyle.transitioningDelegate
            #elseif os(macOS)
            fatalError("unimplemented")
            #endif
        }
        
        _fixSafeAreaInsetsIfNecessary()
    }
    
    public convenience init(rootView: Content) {
        self.init(rootView: rootView, presentationCoordinator: .init())
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    override open func loadView() {
        super.loadView()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let window = view.window, window.canResizeToFitContent {
            window.frame.size = sizeThatFits(in: Screen.main.bounds.size)
        }
    }
    #elseif os(macOS)
    override open func viewDidLayout() {
        super.viewDidLayout()
        
        preferredContentSize = sizeThatFits(in: Screen.main.bounds.size)
    }
    #endif
    
    public func _namedViewDescription(for name: ViewName) -> _NamedViewDescription? {
        _namedViewDescriptions[name]
    }
    
    /// https://twitter.com/b3ll/status/1193747288302075906
    func _fixSafeAreaInsetsIfNecessary() {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        guard let viewClass = object_getClass(view) else {
            return
        }
        
        let className = String(cString: class_getName(viewClass)).appending("_SwiftUIX_patched")
        
        if let viewSubclass = NSClassFromString(className) {
            object_setClass(view, viewSubclass)
        } else {
            className.withCString { className in
                guard let subclass = objc_allocateClassPair(viewClass, className, 0) else {
                    return
                }
                
                if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                    let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                        return .zero
                    }
                    
                    class_addMethod(subclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
                }
                
                if let method2 = class_getInstanceMethod(viewClass, #selector(getter: UIView.safeAreaLayoutGuide))  {
                    let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = { (_: AnyObject!) -> UILayoutGuide? in
                        return nil
                    }
                    
                    class_replaceMethod(viewClass, #selector(getter: UIView.safeAreaLayoutGuide), imp_implementationWithBlock(safeAreaLayoutGuide), method_getTypeEncoding(method2))
                }
                
                objc_registerClassPair(subclass)
                object_setClass(view, subclass)
            }
        }
        #endif
    }
}

#endif
