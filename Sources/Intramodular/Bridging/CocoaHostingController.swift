//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: AppKitOrUIKitHostingController<CocoaHostingControllerContent<Content>>, CocoaController {
    var _safeAreaInsetsAreFixed: Bool = false
    var _namedViewDescriptions: [AnyHashable: _NamedViewDescription] = [:]
    var _presentationCoordinator: CocoaPresentationCoordinator
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    var _transitioningDelegate: UIViewControllerTransitioningDelegate? {
        didSet {
            transitioningDelegate = _transitioningDelegate
        }
    }
    #endif
    var _isResizingParentWindow: Bool = false
    var _didResizeParentWindowOnce: Bool = false
    
    public var mainView: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    public var shouldResizeToFitContent: Bool = false
    
    override public var presentationCoordinator: CocoaPresentationCoordinator {
        _presentationCoordinator
    }
    
    public init(
        mainView: Content,
        presentationCoordinator: CocoaPresentationCoordinator = .init()
    ) {
        self._presentationCoordinator = presentationCoordinator
        
        super.init(
            rootView: .init(
                parent: nil,
                content: mainView
            )
        )
        
        presentationCoordinator.setViewController(self)
        
        self.rootView.parent = self
        
        if let mainView = mainView as? AnyPresentationView {
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            #if os(iOS) || targetEnvironment(macCatalyst)
            hidesBottomBarWhenPushed = mainView.hidesBottomBarWhenPushed
            #endif
            modalPresentationStyle = .init(mainView.modalPresentationStyle)
            presentationController?.delegate = presentationCoordinator
            _transitioningDelegate = mainView.modalPresentationStyle.toTransitioningDelegate()
            #elseif os(macOS)
            fatalError("unimplemented")
            #endif
        }
    }
    
    @available(*, unavailable, renamed: "CocoaHostingController.init(mainView:)")
    public convenience init(rootView: Content) {
        self.init(mainView: rootView, presentationCoordinator: .init())
    }
    
    @_disfavoredOverload
    public convenience init(mainView: Content) {
        self.init(mainView: mainView, presentationCoordinator: .init())
    }
    
    public convenience init(@ViewBuilder mainView: () -> Content) {
        self.init(mainView: mainView())
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
        
        if shouldResizeToFitContent {
            view.invalidateIntrinsicContentSize()
        }
        
        DispatchQueue.main.async {
            self.resizeParentWindowIfNecessary()
        }
    }
    
    override open func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if shouldResizeToFitContent {
            view.invalidateIntrinsicContentSize()
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if shouldResizeToFitContent {
            view.invalidateIntrinsicContentSize()
        }
    }
    
    #elseif os(macOS)
    override open func viewDidLayout() {
        super.viewDidLayout()
        
        preferredContentSize = sizeThatFits(in: Screen.main.bounds.size)
    }
    #endif
    
    public func _namedViewDescription(for name: AnyHashable) -> _NamedViewDescription? {
        _namedViewDescriptions[name]
    }
    
    public func _setNamedViewDescription(_ description: _NamedViewDescription?, for name: AnyHashable) {
        _namedViewDescriptions[name] = description
    }
    
    /// https://twitter.com/b3ll/status/1193747288302075906
    public func _fixSafeAreaInsetsIfNecessary() {
        defer {
            _safeAreaInsetsAreFixed = true
        }
        
        guard !_safeAreaInsetsAreFixed else {
            return
        }
               
        _fixSafeAreaInsets()
    }
        
    private func resizeParentWindowIfNecessary() {
        guard !_didResizeParentWindowOnce else {
            return
        }
        
        guard !_isResizingParentWindow else {
            return
        }

        _isResizingParentWindow = true
        
        defer {
            _isResizingParentWindow = false
        }
        
        #if os(iOS)
        if let window = view.window, window.canResizeToFitContent, view.frame.size.isAreaZero || view.frame.size == Screen.size {
            window.frame.size = self.sizeThatFits(AppKitOrUIKitLayoutSizeProposal(targetSize: Screen.main.bounds.size))
            
            _didResizeParentWindowOnce = true
        }
        #endif
    }
}

extension AppKitOrUIKitHostingController {
    /// https://twitter.com/b3ll/status/1193747288302075906
    public func _fixSafeAreaInsets() {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        guard let viewClass = object_getClass(view), !String(cString: class_getName(viewClass)).hasSuffix("_SwiftUIX_patched") else {
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

            view.setNeedsDisplay()
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        #endif
    }
}

// MARK: - Auxiliary Implementation -

final class _FixSafeAreaInsetsPreferenceKey: TakeLastPreferenceKey<Bool> {
    
}

extension View {
    public func _fixSafeAreaInsets() -> some View {
        preference(key: _FixSafeAreaInsetsPreferenceKey.self, value: true)
    }
}

#endif
